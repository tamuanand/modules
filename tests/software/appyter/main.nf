#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { APPYTER } from '../../../software/appyter/main.nf' addParams( appyter_image: "maayanlab/appyter-example:0.0.3-0.12.2" )

workflow test_appyter {
    def input = []
    input = file("${launchDir}/tests/software/appyter/input.json", checkIfExists: true)
    input_dir = file("${launchDir}/tests/software/appyter/input", checkIfExists: true)
    APPYTER ( input, input_dir )
}
