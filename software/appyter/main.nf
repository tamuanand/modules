// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process APPYTER {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process)) }

    // FIXME These rely on docker and won't work with conda
    // conda (params.enable_conda ? "bioconda::fastqc=0.11.9" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "${params.appyter_image}"
    } else {
        container "${params.appyter_image}"
    }

    input:
    path input_json
    path input_files

    output:
    path "output.ipynb", emit: output_notebook
    // TODO path  "*.version.txt"   , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)

    """
    CURRENTWORK=`pwd`
    cp $input_json ~
    cp $input_files ~
    cd ~
    appyter nbconstruct -i $input_json -o output.ipynb
    appyter nbexecute output.ipynb
    cp output.ipynb \$CURRENTWORK
    """
}
