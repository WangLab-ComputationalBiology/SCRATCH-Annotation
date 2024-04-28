process SCYTPE_STATE_ANNOTATION {

    tag "Performing analysis ${notebook.baseName}"
    label 'process_medium'

    container 'nf-quarto:latest'

    input:
        path(notebook)
        path(config)

        val(project_name)
        val(paramC)

    output:
        path("_freeze/${notebook.baseName}"),   emit: cache

    when:
        task.ext.when == null || task.ext.when

    script:
        def project_name = project_name ? "-P project_name:${project_name}" : ""
        def paramC       = paramC       ? "-P paramC:${paramC}" : ""
        """
        quarto render ${notebook} ${project_name} ${paramC}
        """
    stub:
        """
        mkdir -p _freeze && touch Empty
        """

}

