#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { HELPER_SEURAT_SUBSET      } from '../../modules/local/helpers/subset/main.nf'
include { HELPER_SCEASY_CONVERTER   } from '../../modules/local/helpers/convert/main.nf'
include { CELLTYPIST_ANNOTATION     } from '../../modules/local/celltypist/main.nf'
include { SCYTPE_MAJOR_ANNOTATION   } from '../../modules/local/sctype/major/main.nf'
include { SCYTPE_STATE_ANNOTATION   } from '../../modules/local/sctype/state/main.nf'

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
        ch_notebook_celltypist = Channel.fromPath(params.notebook_celltypist, checkIfExists: true)
        ch_notebook_scytpe_mj  = Channel.fromPath(params.notebook_sctype_major, checkIfExists: true)
        ch_notebook_scytpe_st  = Channel.fromPath(params.notebook_sctype_state, checkIfExists: true)

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

        // Performing automatic annotation with Celltypist
        ch_celltypist = CELLTYPIST_ANNOTATION(
            ch_notebook_celltypist,
            ch_anndata_object,
            ch_page_config
        )
        
        // Performing scType hierarchical annotation - Major cell type
        ch_sctype_major = SCYTPE_MAJOR_ANNOTATION(
            ch_notebook_scytpe_mj,
            ch_filtered_object,
            ch_page_config
        )

        ch_sctype_major_object = ch_sctype_major.seurat_rds
        ch_sctype_major_object
            .view()

        // Reading major cell list
        ch_major_list = ch_sctype_major.major_list
            .splitText()
            .map{ it -> it.split(":") }
            .filter{ !(it[0] =~ "Unknown|Fibroblast|NK_Cells|Plasma") }
            .map{ it[0] }

        ch_major_list
            .view()

        // Combining multiple inputs at once
        ch_state_combine = ch_notebook_scytpe_st
            .combine(ch_sctype_major_object)
            .combine(ch_major_list)
            .combine(ch_page_config)

        ch_state_combine
            .view()

        // Performing scType hierarchical annotation - Subtypes/states cell type
        ch_sctype_state = SCYTPE_STATE_ANNOTATION(
            ch_state_combine
        )

        // ch_sctype_state
        //     .view()

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
