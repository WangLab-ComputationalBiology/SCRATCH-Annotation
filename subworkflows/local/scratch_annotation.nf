#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { HELPER_SEURAT_SUBSET                                 } from '../../modules/local/helpers/subset/main.nf'
include { HELPER_SCEASY_CONVERTER as SCEASY_CONVERTER_ONE      } from '../../modules/local/helpers/convert/main.nf'
include { CELLTYPIST_ANNOTATION                                } from '../../modules/local/celltypist/main.nf'
include { SCYTPE_MAJOR_ANNOTATION                              } from '../../modules/local/sctype/major/main.nf'
include { SCYTPE_STATE_ANNOTATION                              } from '../../modules/local/sctype/state/main.nf'
include { SCYTPE_AGGREGATE_ANNOTATION                          } from '../../modules/local/sctype/aggregate/main.nf'
include { HELPER_SCEASY_CONVERTER as SCEASY_CONVERTER_TWO      } from '../../modules/local/helpers/convert/main.nf'

// include { METATIME_ANNOTATION       } from '../../modules/local/sctype/state/main.nf'

// include { QUARTO_RENDER_PROJECT     } from '../../modules/local/report/main'

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
        ch_notebook_scytpe_ag  = Channel.fromPath(params.notebook_sctype_agg, checkIfExists: true)

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
        if(params.input_cell_mask.contains("NO_FILE")) {
            ch_filtered_object = ch_single_object
        }

        ch_anndata_object = SCEASY_CONVERTER_ONE(
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
            ch_database,
            ch_page_config
        )

        ch_sctype_major_object = ch_sctype_major.seurat_rds

        // Reading major cell list
        ch_major_list = ch_sctype_major.major_list
            .splitText()
            .map{ it -> it.split(":") }
            .filter{ !(it[0] =~ "Unknown|Fibroblast|NK_Cells") }
            .map{ it[0].trim() }

        ch_sctype_state = SCYTPE_STATE_ANNOTATION(
            ch_notebook_scytpe_st,
            ch_sctype_major_object,
            ch_database,
            ch_major_list,
            ch_page_config
        )

        // Aggregating cell annotation
        ch_sctype_agg = ch_sctype_state.annotation
            .collect()

        ch_sctype_agg = SCYTPE_AGGREGATE_ANNOTATION(
            ch_notebook_scytpe_ag,
            ch_sctype_major_object,
            ch_sctype_agg,
            ch_page_config
        )

        SCEASY_CONVERTER_TWO(
            ch_sctype_agg.seurat_rds
        )
        
    emit:
        ch_dumps = Channel.empty()

}
