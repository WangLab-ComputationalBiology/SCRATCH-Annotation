process CREATE_DATA {

    tag    "Creating test data for annotation"
    label 'process_medium'

    container 'syedsazaidi/scratch-annotation:latest'

    input: 
        path(cell_markers_database)

    output:
        path("sr_tiny.rds") ,      emit: sr_tiny
        path("sr_ref_tiny.rds") ,  emit: sr_ref_tiny

    script:
    template 'make-test-seurat.r'
}