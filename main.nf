#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_ANNOTATION } from './subworkflows/local/scratch_annotation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {

    ch_matrix = Channel.fromPath(params.matrix)
    ch_annotation_dabatase = Channel.empty()

    SCRATCH_ANNOTATION(
        ch_matrix,
        ch_annotation_dabatase
    )

}
