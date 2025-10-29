process HELPER_SEURAT_SUBSET {

    tag "Removing malignant cells"
    label 'process_medium'

    // container 'oandrefonseca/scratch-annotation:main'
    // container 'syedsazaidi/scratch-annotation:v1.0'
    // container '/home/sazaidi/Softwares/SCRATCH-Annotation-dev/scratch-annotation.sif'
    container 'syedsazaidi/scratch-annotation:latest'
    
    publishDir "${params.outdir}/data/${task.process}", mode: 'copy', overwrite: true

    input:
        path(seurat_object)
        path(cell_malignancy)

    output:
        path("${seurat_object.baseName}_filtered.RDS") ,  emit: project_rds

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        seurat_subset.R -f ${seurat_object} -m ${cell_malignancy}
        """
    stub:
        """
        touch ${seurat_object.baseName}_filtered.RDS
        """

}
