#!/usr/bin/env nextflow


// Import workflow modules
include { PIPELINE } from './workflows/pipeline'
include { INIT } from './workflows/init'
include { PRINT_VERSION; SAVE_INFO } from './workflows/info_and_version'


params {
    init: Boolean
    version: Boolean
    help: Boolean
    reads: String
    output: String
    db: String
    file_publish: String
    spneumo_percentage: Float
    non_strep_percentage: Float
    ref_coverage: Float
    het_snp_site: Integer
    contigs: Integer
    length_low: Integer
    length_high: Integer
    depth: Float
    assembler: String
    assembler_thread: Integer
    min_contig_length: Integer
    ref_genome: String
    kraken2_db_remote: String
    kraken2_memory_mapping: Boolean
    seroba_db_remote: String
    seroba_kmer: Integer
    poppunk_db_remote: String
    poppunk_ext_remote: String
    ariba_ref: String
    ariba_metadata: String
    resistance_to_mic: String
    annotation: Boolean
    bakta_db_remote: String
    lite: Boolean
    singularity_cachedir: String?
}

workflow {
    main:
    // Start message
    Messages.startMessage(workflow.manifest.version, log)

    // Validate parameters
    Validate.validate(params, workflow, log)

    // Check selected workflow
    String selectedWorkflow =   params.help ? 'help' : 
                                params.init ? 'init' : 
                                params.version ? 'version' : 
                                'pipeline'

    // If Singularity is used as the container engine and not showing help message, do preflight check to prevent parallel pull issues
    // Related issue: https://github.com/nextflow-io/nextflow/issues/1210
    if (workflow.containerEngine == 'singularity' && selectedWorkflow != 'help') {
        Singularity.singularityPreflight(workflow.container, params.singularity_cachedir, log)
    }

    // Select workflow with PIPELINE as default
    if (selectedWorkflow == 'help') {
        Messages.helpMessage(log)
    } else {
        Messages.workflowSelectMessage(selectedWorkflow, params.reads, workflow.outputDir.toString(), log)
        if (selectedWorkflow == 'init')  {
            INIT(
                params.annotation,
                params.db,
                params.ref_genome,
                params.ariba_ref,
                params.ariba_metadata,
                params.kraken2_db_remote,
                params.seroba_db_remote,
                params.seroba_kmer,
                params.poppunk_db_remote,
                params.poppunk_ext_remote,
                params.bakta_db_remote
            )
        } else if (selectedWorkflow == 'version') {
            PRINT_VERSION(
                params.resistance_to_mic, 
                workflow.manifest.version,
                params.db,
                params.assembler
            )
        } else if (selectedWorkflow == 'pipeline') {
            PIPELINE(
                params.annotation,
                params.lite,
                params.db,
                params.ref_genome,
                params.ariba_ref,
                params.ariba_metadata,
                params.kraken2_db_remote,
                params.seroba_db_remote,
                params.seroba_kmer,
                params.poppunk_db_remote,
                params.poppunk_ext_remote,
                params.bakta_db_remote,
                params.reads,
                params.contigs,
                params.length_low,
                params.length_high,
                params.depth,
                params.min_contig_length,
                params.assembler,
                params.assembler_thread,
                params.ref_coverage,
                params.het_snp_site,
                params.kraken2_memory_mapping,
                params.spneumo_percentage,
                params.non_strep_percentage,
                params.resistance_to_mic
            )
            SAVE_INFO(
                PIPELINE.out.databases_info, 
                params.resistance_to_mic, 
                workflow.manifest.version,
                params.assembler,
                params.assembler_thread,
                params.min_contig_length,
                params.reads,
                workflow.outputDir.toString(),
                params.contigs,
                params.length_low,
                params.length_high,
                params.depth,
                params.spneumo_percentage,
                params.non_strep_percentage,
                params.ref_coverage,
                params.het_snp_site
            )
        }
    }

    // End message
    workflow.onComplete = {
        if (selectedWorkflow == 'help') return
        
        Messages.endMessage(selectedWorkflow, workflow.outputDir.toString(), workflow, log)
    }

    // Publish empty channels if pipeline workflow is not selected
    publish:
    overall_report  = selectedWorkflow != 'pipeline' ? channel.empty() : PIPELINE.out.overall_report
    info            = selectedWorkflow != 'pipeline' ? channel.empty() : SAVE_INFO.out.info
    assemblies      = selectedWorkflow != 'pipeline' ? channel.empty() : PIPELINE.out.assemblies
    annotations     = selectedWorkflow != 'pipeline' ? channel.empty() : PIPELINE.out.annotations
}

output {
    overall_report {
        path '.'
    }
    info {
        path '.'
    }
    assemblies {
        path 'assemblies'
    }
    annotations {
        path 'annotations'
    }
}
