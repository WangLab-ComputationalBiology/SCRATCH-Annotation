#!/usr/bin/env Rscript

library(Seurat)

set.seed(42)


#get the cell_markers_database (normally from assets)
cmdb <- read.csv("${cell_markers_database}", stringsAsFactors = FALSE)


# create a tiny Seurat object for testing purposes
# below 2500 Seurat AddModuleScore fails with error described below
# https://github.com/satijalab/seurat/issues/4819#issuecomment-2825615354
n_markers <- 200
n_genes <- 2500
n_cells <- 1000
genes <- sample(unique(cmdb[["markers"]]), n_markers, replace = FALSE)

# add some dummy genes to please Seurat's AddModuleScore and pipeline
genes <- c(genes, paste0("TEST", 1:(n_genes - length(genes))))

sr <- CreateSeuratObject(
  counts = matrix(
    data = rnbinom(n_genes * n_cells, size = 1, mu = 100),
    nrow = n_genes,
    ncol = n_cells,
    dimnames = list(
      genes,
      paste0("Cell", 1:n_cells)
    )
  )
)

sr <- NormalizeData(sr)
sr <- FindVariableFeatures(sr)
sr <- ScaleData(sr, features = VariableFeatures(sr))
sr <- RunPCA(sr, features = VariableFeatures(sr))

# sctype module wants seurat_clusters in query
sr[["seurat_clusters"]] <- sample(
  x = c("TypeA", "TypeB", "TypeC"),
  size = n_cells,
  replace = TRUE
)

saveRDS(sr, file = "sr_tiny.rds")

# a tiny reference Seurat object with seurat_annotation column for azimuth
n_cells_ref <- 1000
sr_ref <- CreateSeuratObject(
  counts = matrix(
    data = rnbinom(n_genes * n_cells_ref, size = 1, mu = 100),
    nrow = n_genes,
    ncol = n_cells_ref,
    dimnames = list(
      genes,
      paste0("Cell", 1:n_cells_ref)
    )
  )
)

# azimuth wants seurat annotations in ref
sr_ref[["seurat_annotations"]] <- sample(
  x = c("TypeA", "TypeB", "TypeC"),
  size = n_cells_ref,
  replace = TRUE
)

sr_ref <- NormalizeData(sr_ref)
sr_ref <- FindVariableFeatures(sr_ref)
sr_ref <- ScaleData(sr_ref, features = VariableFeatures(sr_ref))

# azimuth also wants PCA in ref
sr_ref <- RunPCA(sr_ref, features = VariableFeatures(sr_ref))

saveRDS(sr_ref, file = "sr_ref_tiny.rds")
