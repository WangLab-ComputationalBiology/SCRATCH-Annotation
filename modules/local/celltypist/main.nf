process CELLTYPIST_ANNOTATION {

    tag "Performing analysis ${notebook.baseName}"
    label 'process_medium'

    container 'nf-quarto:latest'

    input:
        path(notebook)
        path(anndata_object)
        path(config)

    output:
        path("_freeze/${notebook.baseName}/*"),           emit: cache
        path("${params.project_name}_celltypist.h5ad") ,  emit: project_object

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P anndata_object:${anndata_object} ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file}
        """
    stub:
        def param_file = task.ext.args ? "-P anndata_object:${anndata_object} ${task.ext.args}" : ""
        """
        touch ${params.project_name}_celltypist.h5ad
        mkdir -p _freeze/${notebook.baseName}
        touch _freeze/${notebook.baseName}/${notebook.baseName}.html
        echo ${param_file} > _freeze/${notebook.baseName}/params.yml
        """

}
