process SCGPT {

    tag '$bam'
    label 'process_single'

    container ""

    input:
        path bam

    output:

        path "*.bam", emit: bam
        path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        samtools \\
            sort \\
            $args \\
            -@ $task.cpus \\
            $bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
        END_VERSIONS
        """
    stub:
        def args = task.ext.args ?: ''
        """
        touch ${prefix}.bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
