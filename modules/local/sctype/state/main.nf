process SCYTPE_STATE_ANNOTATION {

    tag "Running scType annotation - ${cell_population} subsets/states"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'

    input:
        path(notebook)
        path(seurat_object)
        path(cell_annotation)
        each(cell_population)
        path(config)

    output:
        path("_freeze/notebook_${cell_population}"),                                          emit: cache
        path("data/${params.project_name}_${cell_population}_annotation_object.RDS"),  emit: seurat_rds
        path("data/${params.project_name}_${cell_population}_annotation.csv"),         emit: annotation

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P input_cell_markers_db:${cell_annotation} -P input_parent_level:'${cell_population}' -P ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file} -o notebook_${cell_population}
        """
    stub:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P input_cell_markers_db:${cell_annotation} -P input_parent_level:'${cell_population}' -P ${task.ext.args}" : ""
        """
        mkdir -p _freeze/notebook_${cell_population}
        mkdir -p data

        touch data/${params.project_name}_${cell_population}_annotation_object.RDS
        touch data/${params.project_name}_${cell_population}_annotation.csv

        echo ${param_file} > _freeze/param_file.yml
        """

}

