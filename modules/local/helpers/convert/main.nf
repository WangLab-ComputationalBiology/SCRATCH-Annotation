process QUARTO_RENDER_PAGEB {

    tag "Performing analysis ${notebook.baseName}"
    label 'process_medium'

    container 'oandrefonseca/scagnostic:main'

    input:
        path(notebook)
        path(config)

        val(project_name)
        val(paramB)

    output:
        path("_freeze/${notebook.baseName}"),  emit: cache
        path("${project_name}_step_02.RDS") ,  emit: project_rds

    when:
        task.ext.when == null || task.ext.when

    script:
        def project_name = project_name ? "-P project_name:${project_name}" : ""
        def paramB       = paramB       ? "-P paramB:${paramB}" : ""
        """
        quarto render ${notebook} ${project_name} ${paramB}
        """
    stub:
        """
        """

}
