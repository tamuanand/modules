process BBMAP_CLUMPIFY {
    tag "$meta.id"
    label 'process_large'

    conda (params.enable_conda ? "bioconda::bbmap=38.98" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:38.98--h5c4e2a8_1' :
        'quay.io/biocontainers/bbmap:38.98--h5c4e2a8_1' }"

    input:
    tuple val(meta), path(reads)
    path contaminants

    output:
    tuple val(meta), path('*.fastq.gz'), emit: reads
    tuple val(meta), path('*.log')     , emit: log
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def raw      = meta.single_end ? "in=${reads[0]}" : "in1=${reads[0]} in2=${reads[1]}"
    def clumped  = meta.single_end ? "out=${prefix}.fastq.gz" : "out1=${prefix}_1.fastq.gz out2=${prefix}_2.fastq.gz"    
    """
    maxmem=\$(echo \"$task.memory\"| sed 's/ GB/g/g')
    clumpify.sh \\
        -Xmx\$maxmem \\
        $raw \\
        $clumped \\        
        $args \\        
        &> ${prefix}.clumpify.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bbmap: \$(bbversion.sh)
    END_VERSIONS
    """
}
