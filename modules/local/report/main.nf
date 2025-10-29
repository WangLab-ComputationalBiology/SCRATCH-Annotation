process QUARTO_RENDER_PROJECT {

    tag "Creating final report"
    label 'process_low'

    // container 'oandrefonseca/scratch-annotation:main'
    // container 'syedsazaidi/scratch-annotation:v1.0'
    // container '/home/sazaidi/Softwares/SCRATCH-Annotation-dev/scratch-annotation.sif'
    container 'syedsazaidi/scratch-annotation:latest'

    input:
        path(template)
        path(qmd)
        path(cache), stageAs: '_freeze/*'

    output:
        path("report"), emit: project_folder

    shell:
        """
        quarto render .
        """
}
