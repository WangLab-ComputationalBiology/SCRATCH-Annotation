process HELPER_SCEASY_CONVERTER {

    tag "Converting Seurat to AnnData"
    label 'process_medium'

    container 'oandrefonseca/scratch-annotation:main'
    publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
        path(seurat_object)

    output:
        path("${seurat_object.baseName}_filtered.h5ad") ,  emit: project_rds

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        sceasy_converter.R -f ${seurat_object}
        """
    stub:
        """
        touch ${seurat_object.baseName}_filtered.h5ad
        """

}
