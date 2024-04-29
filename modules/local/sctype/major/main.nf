process SCYTPE_MAJOR_ANNOTATION {

    tag "Performing analysis ${notebook.baseName}"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'
    publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
        path(notebook)
        path(seurat_object)
        path(config)

    output:
        path("_freeze/${notebook.baseName}"),   emit: cache

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file}
        """
    stub:
        """
        mkdir -p _freeze && touch Empty
        """

}

