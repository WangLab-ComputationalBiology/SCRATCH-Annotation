process SCYTPE_AGGREGATE_ANNOTATION {

    tag "Running scType aggregation"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'

    input:
        path(notebook)
        path(seurat_object)
        path(cell_annotation_files)
        path(config)

    output:
        path("_freeze/${notebook.baseName}")                          , emit: cache
        path("data/${params.project_name}_sctype_agg_annotation_object.RDS")   , emit: seurat_rds
        path("report/${notebook.baseName}.html")                      , emit: html

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P cell_annotation_files:'${cell_annotation_files.join(';')}' -P ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file}
        """
    stub:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P cell_annotation_files:'${cell_annotation_files.join(';')}' -P ${task.ext.args}" : ""
        """
        mkdir -p _freeze/${notebook.baseName}
        
        mkdir -p data
        touch data/${params.project_name}_sctype_agg_annotation_object.RDS

        mkdir -p report
        touch report/${notebook.baseName}.html

        echo ${param_file} > _freeze/param_file.yml
        """

}

