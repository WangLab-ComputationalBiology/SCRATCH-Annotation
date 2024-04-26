# SCRATCH Annotation <a href=''><img src="assets/template/SCRATCH.png" alt="SCRATCH" align="right" height="100px" width="95px"/></a>

SCRATCH Annotation is a subworkflow responsible for cell annotation and cell state inference. It leverages both knowledge and reference-based methods for performing cell identification. Note, that `SCRATCH Annotation` was designed to infer TME annotation. As for malignant identification, please refer to our CNV-based subworkflow, `SCRATCH CNV`.

> **Disclaimer:** Subworkflows are chained modules providing a high-level functionality (e.g., Alignment, QC, Differential expression) within a pipeline context. These subworkflows should ideally be bundled with the pipeline implementation and shared among different pipelines as needed.

## Installation

```bash
git clone https://github.com/WangLab-ComputationalBiology/SCRATCH-Annotation.git
```

## Getting started

The `Annotation` step can handle Seurat objects as input. The subworkflow will execute 1) three annotation packages (e.g., scType, CellTypist, and scVI), 2) provide plots for improving interpretability, and 3) a qualitative comparison across methods based on Tabula Sapiens [protocol](https://tabula-sapiens-portal.ds.czbiohub.org/annotateuserdata). Additionally, the pipeline contains a built-in marker database, [see](./assets/cell_markers_database.csv)

## Expected outputs



