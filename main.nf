#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_ANNOTATION } from './subworkflows/local/scratch_annotation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    ch_matrix   = Channel.fromPath(params.matrix)
    ch_database = Channel.empty()

    SCRATCH_ANNOTATION(
        ch_matrix,
        ch_database
    )

}

workflow.onComplete {
    log.info(
        workflow.success ? "\nDone! Open the following report in your browser -> ${launchDir}/${params.project_name}/report/index.html\n" :
                           "Oops... Something went wrong"
    )
}
