#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


// include { QUARTO_RENDER_PAGEB   } from '../../modules/local/metatime/annotation/main'
// include { QUARTO_RENDER_PAGEC   } from '../../modules/local/sctype/main'

include { HELPER_SEURAT_SUBSET      } from '../../modules/local/helpers/subset/main.nf'
include { HELPER_SCEASY_CONVERTER   } from '../../modules/local/helpers/convert/main.nf'
include { CELLTYPIST_ANNOTATION     } from '../../modules/local/celltypist/main.nf'
// include { SCYTPE_MAJOR_ANNOTATION   } from '../../modules/local/sctype/main.nf'
// include { SCYTPE_STATE_ANNOTATION   } from '../../modules/local/sctype/main.nf'


// include { QUARTO_RENDER_PROJECT } from '../../modules/local/report/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SCRATCH_ANNOTATION {

    take:
        ch_single_object    // channel: []
        ch_cell_malignancy  // channel: []
        ch_database         // channel: []

    main:

        // Importing notebook
        ch_notebookA   = Channel.fromPath(params.notebookA, checkIfExists: true)
        ch_celltypist  = Channel.fromPath(params.notebook_celltypist, checkIfExists: true)
        ch_notebookC   = Channel.fromPath(params.notebookC, checkIfExists: true)

        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()

        // Subsetting based on cell malignancy annotation
        ch_filtered_object = HELPER_SEURAT_SUBSET(
            ch_single_object,
            ch_cell_malignancy
        )

        ch_filtered_object
            .ifEmpty("Malignant cells were not filtered. Running annotation in all cells.")
            .view()

        // Object/Data interoperability
        if(params.cell_mask.contains("NO_FILE")) {
            ch_filtered_object = ch_single_object
        }

        ch_anndata_object = HELPER_SCEASY_CONVERTER(
            ch_filtered_object
        )

        // // Passing notebooks for respective functions
        celltypist = CELLTYPIST_ANNOTATION(
            ch_celltypist,
            ch_anndata_object,
            ch_page_config
        )
        
        // second = QUARTO_RENDER_PAGEB(
        //     ch_notebookB,
        //     ch_filtered_object,
        //     ch_page_config,
        // )

        // // Adding conditions for skipping notebooks/analysis
        // (ch_notebookC, third) = params.skip_python
        //     ? [Channel.empty(), Channel.empty()]
        //     : [
        //         ch_notebookC,
        //         QUARTO_RENDER_PAGEC(
        //             ch_notebookC,
        //             ch_page_config,
        //             params.project_name,
        //             params.paramC
        //         )
        //     ]

        // // Gathering all notebooks
        // ch_qmd = ch_notebookA.mix(ch_notebookB, ch_notebookC)
        //     .collect()

        // // Creates a single channel with all cache/freeze folders
        // ch_cache = first.mix(second.cache, third)
        //     .collect()

        // // Load SCRATCH/BTC template
        // ch_template = ch_template
        //     .collect()

        // // Inspecting channels content
        // ch_cache.view()
        // ch_page_config.view()
        // ch_qmd.view()

        // // Gathering intermediate pages and rendering the project
        // QUARTO_RENDER_PROJECT(
        //     ch_template,
        //     ch_qmd,
        //     ch_cache
        // )

    emit:
        ch_dumps = Channel.empty()

}
