# SCRATCH Annotation Subworkflow

## Introduction
SCRATCH Annotation is a subworkflow responsible for cell annotation and cell state inference. It leverages both knowledge and reference-based methods for performing cell identification. Note, that `SCRATCH Annotation` was designed to infer TME annotation. As for malignant identification, please refer to our CNV-based subworkflow, `SCRATCH CNV`.

> **Disclaimer:** Subworkflows are chained modules providing a high-level functionality (e.g., Alignment, QC, Differential expression) within a pipeline context. These subworkflows should ideally be bundled with the pipeline implementation and shared among different pipelines as needed.

## Prerequisites
Before running the subworkflow, ensure you have the following installed:
- [Nextflow](https://www.nextflow.io/) (version 21.04.0 or higher)
- [Java](https://www.oracle.com/java/technologies/javase-downloads.html) (version 8 or higher)
- [Docker](https://www.docker.com/) or [Singularity](https://sylabs.io/singularity/) for containerized execution
- [Git](https://git-scm.com/)

## Installation
Clone the repository to your local machine:
```bash
git clone https://github.com/WangLab-ComputationalBiology/SCRATCH-Annotation.git
cd SCRATCH-Annotation
```

## Usage
To run the subworkflow, use the following command:
```bash
nextflow run main.nf -profile [docker/singularity] --input_seurat_object <path/to/seurat_object.RDS> --annotation_db <path/to/annotation_db> --project_name <project_name>
```

### Parameters
- `--input_seurat_object`: Path to the Seurat object input file (default: `data/Yost_main_cluster_object.RDS`).
- `--annotation_db`: Path to the annotation database file (default: `assets/cell_markers_database.csv`).
- `--input_cell_mask`: Path to the cell mask file (default: `data/Yost_main_cell_status.csv`).
- `--outdir`: Output directory (default: `launchDir`).
- `--project_name`: Name of the project for organizing results (default: `project`).
- `--organism`: Organism for annotation, either "Human" or "Mouse" (default: `Human`).
- `--thr_n_features`: Threshold for the number of features (default: `2000`).
- `--thr_npc`: Threshold for the number of principal components (default: `25`).
- `--thr_resolution`: Threshold for resolution (default: `0.50`).
- `--skip_celltypist`: Skip CellTypist annotation (default: `false`).
- `--skip_sctype`: Skip scType annotation (default: `false`).

### Example
```bash
nextflow run main.nf -profile docker --input_seurat_object data/Yost_main_cluster_object.RDS --annotation_db assets/cell_markers_database.csv --input_cell_mask data/Yost_main_cell_status.csv --outdir ./results --project_name Annotation_Project --organism Human --thr_n_features 2000 --thr_npc 25 --thr_resolution 0.50 --skip_celltypist false --skip_sctype false
```

## Configuration
The subworkflow can be configured using the `nextflow.config` file. Modify this file to set default parameters, profiles, and other settings.

## Output
Upon successful completion, the results will be available in a directory named after your project (`<project_name>`). You can open the report in your browser:
```plaintext
Done! Open the following report in your browser -> <path/to/launchDir>/<project_name>/report/index.html
```

## Documentation
For more detailed documentation and advanced usage, refer to the [Nextflow documentation](https://www.nextflow.io/docs/latest/index.html) and the comments within the subworkflow script (`main.nf`).

## Contributing
Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

## License
This project is available under the GNU General Public License v3.0. See the LICENSE file for more details.

## Contact
For questions or issues, please contact:
- oandrefonseca@gmail.com
- lwang22@mdanderson.org
- ychu2@mdanderson.org
