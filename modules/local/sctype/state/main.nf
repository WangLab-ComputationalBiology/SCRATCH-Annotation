process SCYTPE_STATE_ANNOTATION {

    tag "Running scType annotation - ${cell_population} subset/State cells"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'
    publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
        path(notebook)
        path(seurat_object)
        val(cell_population)
        path(config)

    output:
        path("_freeze/${notebook.baseName}"),                               emit: cache
        path("data/${params.project_name}_subtype_annotation_object.RDS"),  emit: seurat_rds
        path("data/${params.project_name}_subtype_annotation.csv"),         emit: annotation
        path("data/${params.project_name}_subtype_annotation.list.txt"),    emit: major_list

    when:
        task.ext.when == null || task.ext.when

    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P input_cell_population:"${cell_population}" -P ${task.ext.args}" : ""
        """
        quarto render ${notebook} ${param_file}
        """
    stub:
        """
        mkdir -p _freeze/${notebook.baseName}
        mkdir -p data

        touch data/${params.project_name}_subtype_annotation_object.RDS
        touch data/${params.project_name}_subtype_annotation.csv
        touch data/${params.project_name}_subtype_annotation.list.txt

        echo ${param_file} > _freeze/param_file.yml
        """

}

