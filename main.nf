#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_ANNOTATION } from './subworkflows/local/scratch_annotation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Check mandatory parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (params.input_seurat_object) { input_seurat_object = file(params.input_seurat_object) } else { exit 1, 'Please, provide a --input <PATH/TO/seurat_object.RDS> !' }
if (params.annotation_db) { annotation_db = file(params.annotation_db) } else { exit 1, 'Please check the assets folder.' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    log.info """\

        Parameters:

        Input: ${input_seurat_object}
        DB: ${annotation_db}

    """

    // Mandatory inputs
    ch_single_object    = Channel.fromPath(input_seurat_object, checkIfExists: true)
    ch_database         = Channel.fromPath(annotation_db, checkIfExists: true)

    // Optional inputs
    ch_cell_malignancy = Channel.fromPath(params.input_cell_mask)
    ch_reference_object = Channel.fromPath(params.input_reference_object, checkIfExists: true)

    // Running subworkflows
    SCRATCH_ANNOTATION(
        ch_single_object,
        ch_cell_malignancy,
        ch_database,
        ch_reference_object
    )

}

workflow.onComplete {
    log.info(
        workflow.success ? "\nDone! Open the following report in your browser -> ${launchDir}/report/index.html\n" :
                           "Oops... Something went wrong"
    )
}
