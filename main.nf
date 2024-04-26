#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_ANNOTATION } from './subworkflows/local/scratch_annotation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Check mandatory parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (params.input) { seurat_object = file(params.input) } else { exit 1, 'Please, provide a --input <PATH/TO/seurat_object.RDS> !' }
if (params.annotation_db) { annotation_db = file(params.annotation_db) } else { exit 1, 'Please check the assets folder.' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    // Mandatory inputs
    ch_single_object   = Channel.fromPath(seurat_object)
    ch_database        = Channel.fromPath(annotation_db)

    // Optional inputs
    ch_cell_malignancy = Channel.fromPath(params.cell_mask)

    // Running subworkflows
    SCRATCH_ANNOTATION(
        ch_single_object,
        ch_cell_malignancy,
        ch_database
    )

    // SCRATCH_HARMONIZATION()

}

workflow.onComplete {
    log.info(
        workflow.success ? "\nDone! Open the following report in your browser -> ${launchDir}/${params.project_name}/report/index.html\n" :
                           "Oops... Something went wrong"
    )
}
