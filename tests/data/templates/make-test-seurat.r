#!/usr/bin/env Rscript

library(Seurat)

set.seed(42)

# get the cell_markers_database (normally from assets)
cmdb <- read.csv("${cell_markers_database}", stringsAsFactors = FALSE)

# create a tiny Seurat object for testing purposes
make_small_seurat <- function(cmdb, ncell_each = 100) {
  # below 2500 genes Seurat AddModuleScore fails with error described below
  # https://github.com/satijalab/seurat/issues/4819#issuecomment-2825615354

  lineage <- cmdb[cmdb["parent_level"] == "Lineage_markers",
                  c("parent_level", "cell_annotation", "markers")]
  detailed <- cmdb[cmdb["parent_level"] != "Lineage_markers",
                   c("parent_level", "cell_annotation", "markers")]
  cell_types <- unique(detailed[["cell_annotation"]])

  # add cells that are in the lineage but not in the detailed list
  missing <- setdiff(unique(lineage[["cell_annotation"]]),
                     unique(detailed[["parent_level"]]))
  cell_types <- c(cell_types, missing)

  # create counts from negative binomial based on the cell types in the cmdb
  counts_list <- lapply(cell_types, function(cell_type) {
    cell_type_genes <- detailed[detailed[["cell_annotation"]] == cell_type,
                                "markers"]

    parent <- detailed[["parent_level"]][detailed[["cell_annotation"]]==cell_type]
    parent <- unique(parent)

    #check that the detailed cell type has only one parent in the cmdb
    if(length(parent) > 1) {
      stop(paste("Cell type", cell_type, "has multiple parents in the cmdb"))
    } else if (length(parent)==0) {
      parent <- cell_type # if the cell type is not in the lineage, it is its own parent
    }

    lineage_genes <- lineage[lineage[["cell_annotation"]] == parent,
                             "markers"]
    cell_type_genes <- unique(c(lineage_genes, cell_type_genes))

    ct <- matrix(
      data = rnbinom(length(cell_type_genes) * ncell_each, size = 1, mu = 100),
      nrow = length(cell_type_genes),
      ncol = ncell_each,
      dimnames = list(
        cell_type_genes,
        paste0("Cell", 1:ncell_each)
      )
    ) |> t() |> as.data.frame()
    ct[["major_type"]] <- parent # preserve cell names for after rbind.fill
    ct
  })

  counts <- do.call(plyr::rbind.fill, counts_list)
  counts[is.na(counts)] <- 0
  rownames(counts) <- paste0(counts[["major_type"]], 1:nrow(counts))
  counts["major_type"] <- NULL

  # if resulting counts has less than 2500 genes, add random genes to reach 2500
  if (ncol(counts) < 2500) {
    n_genes_to_add <- 2500 - ncol(counts)
    random_genes <- paste0("DUMMY", seq_len(n_genes_to_add))
    random_counts_matrix <- matrix(
      data = rnbinom(nrow(counts) * n_genes_to_add, size = 1, mu = 100),
      nrow = nrow(counts),
      ncol = n_genes_to_add,
      dimnames = list(rownames(counts), random_genes)
    )
    # set 80% of the random counts to 0 to make them more realistic
    n_elements <- length(random_counts_matrix)
    zeroes <- sample(n_elements, size = floor(n_elements * 0.8))
    random_counts_matrix[zeroes] <- 0
    random_counts <- as.data.frame(random_counts_matrix)
    counts <- cbind(counts, random_counts)
  }

  sr <- CreateSeuratObject(counts = t(as.matrix(counts)))
  sr <- NormalizeData(sr)
  sr <- FindVariableFeatures(sr)
  sr <- ScaleData(sr, features = VariableFeatures(sr))
  sr <- RunPCA(sr, features = VariableFeatures(sr))
  sr <- FindNeighbors(sr, dims = 1:10)
  sr <- FindClusters(sr, resolution = 0.5) #create seurat_clusters sctype needs

  sr
}

# a small input Seurat object for testing
sr <- make_small_seurat(cmdb, ncell_each = 100)
# sctype module wants patient_id in the metadata
sr[["patient_id"]] <- "Patient1"
saveRDS(sr, file = "sr_tiny.rds")

# simulate cell malignancy status metadata for testing
cell_status <- data.frame(
  barcode = colnames(sr),
  cell_status = sample(c("TME", "Malignant"), size = ncol(sr), replace = TRUE)
)
write.csv(cell_status, file = "cell_status.csv", row.names = FALSE)

# a small ref Seurat object for testing
sr_ref <- make_small_seurat(cmdb, ncell_each = 100)

# azimuth needs seurat_annotations, make one from original cell names
sr_ref[["seurat_annotations"]] <- gsub("[0-9]+", "", rownames(sr_ref@meta.data))
saveRDS(sr_ref, file = "sr_ref_tiny.rds")

