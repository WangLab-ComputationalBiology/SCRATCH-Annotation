#!/usr/bin/env Rscript

library(Seurat)

set.seed(42)

#create a tiny Seurat object for testing purposes
sr <- CreateSeuratObject(
  counts = matrix(
    data = rpois(n = 20000, lambda = 10),
    nrow = 200,
    ncol = 100,
    dimnames = list(
      paste0("Gene", 1:200),
      paste0("Cell", 1:100)
    )
  )
)

sr <- NormalizeData(sr)
sr <- FindVariableFeatures(sr)
sr <- ScaleData(sr, features = VariableFeatures(sr))
sr <- RunPCA(sr, features = VariableFeatures(sr))

saveRDS(sr, file = "sr_tiny.rds")

#create a tiny reference Seurat object with seurat_annotation column for
sr_ref <- CreateSeuratObject(
  counts = matrix(
    data = rpois(n = 40000, lambda = 10),
    nrow = 200,
    ncol = 200,
    dimnames = list(
      paste0("Gene", 1:200),
      paste0("Cell", 1:200)
    )
  )
)


sr_ref[["seurat_annotations"]] <- sample(
  x = c("TypeA", "TypeB"),
  size = 200,
  replace = TRUE
)

sr_ref <- NormalizeData(sr_ref)
sr_ref <- FindVariableFeatures(sr_ref)
sr_ref <- ScaleData(sr_ref, features = VariableFeatures(sr_ref))
sr_ref <- RunPCA(sr_ref, features = VariableFeatures(sr_ref))

saveRDS(sr_ref, file = "sr_ref_tiny.rds")
