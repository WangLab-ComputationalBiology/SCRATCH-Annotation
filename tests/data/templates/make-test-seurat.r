#!/usr/bin/env Rscript

library(Seurat)

set.seed(42)


#get the cell_markers_database (normally from assets)
cmdb <- read.csv("${cell_markers_database}", stringsAsFactors = FALSE)


#create a tiny Seurat object for testing purposes
n_genes <- 200
n_cells <- 1000
genes <- sample(unique(cmdb[["markers"]]), n_genes, replace = FALSE)
sr <- CreateSeuratObject(
  counts = matrix(
    data = rpois(n = n_genes * n_cells, lambda = 10),
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

#sctype wants seurat_clusters in query
sr[["seurat_clusters"]] <- sample(
  x = c("TypeA", "TypeB", "TypeC"),
  size = n_cells,
  replace = TRUE
)

saveRDS(sr, file = "sr_tiny.rds")

#create a tiny reference Seurat object with seurat_annotation column for azimuth anotation
n_cells_ref <- 1000
sr_ref <- CreateSeuratObject(
  counts = matrix(
    data = rpois(n = n_genes * n_cells_ref, lambda = 10),
    nrow = n_genes,
    ncol = n_cells_ref,
    dimnames = list(
      genes,
      paste0("Cell", 1:n_cells_ref)
    )
  )
)

#azimuth wants seurat annotations in ref
sr_ref[["seurat_annotations"]] <- sample(
  x = c("TypeA", "TypeB", "TypeC"),
  size = n_cells_ref,
  replace = TRUE
)


sr_ref <- NormalizeData(sr_ref)
sr_ref <- FindVariableFeatures(sr_ref)
sr_ref <- ScaleData(sr_ref, features = VariableFeatures(sr_ref))
sr_ref <- RunPCA(sr_ref, features = VariableFeatures(sr_ref))

saveRDS(sr_ref, file = "sr_ref_tiny.rds")
