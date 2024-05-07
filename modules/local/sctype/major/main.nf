process SCYTPE_MAJOR_ANNOTATION {

    tag "Running scType annotation - Major cells"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'

    input:
        path(notebook)
        path(seurat_object)
        path(cell_annotation)
        path(config)

    output:
        path("_freeze/${notebook.baseName}")                             , emit: cache
        path("data/${params.project_name}_major_annotation_object.RDS")  , emit: seurat_rds
        path("data/${params.project_name}_major_annotation.csv")         , emit: annotation
        path("data/${params.project_name}_major_annotation.list.txt")    , emit: major_list
        path("report/${notebook.baseName}.html")                         , emit: html

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P input_cell_markers_db:${cell_annotation} -P ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file}
        """
    stub:
        """
        mkdir -p _freeze/${notebook.baseName}
        mkdir -p data

        touch data/${params.project_name}_major_annotation_object.RDS
        touch data/${params.project_name}_major_annotation.csv

        mkdir -p report
        touch report/${notebook.baseName}.html

        echo "B_Plasma_Cells\nEndothelial_Cells\nEpithelial\nFibroblast\nMyeloid\nNK_Cells\nT_Cells" > data/${params.project_name}_major_annotation.list.txt
        """

}

