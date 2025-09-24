#!/usr/bin/env nextflow


// Import workflow modules
include { PIPELINE } from './workflows/pipeline'
include { INIT } from './workflows/init'
include { PRINT_VERSION; SAVE_INFO } from './workflows/info_and_version'


workflow {
    // Start message
    Messages.startMessage(workflow.manifest.version, log)

    // Validate parameters
    Validate.validate(params, workflow, log)

    // If Singularity is used as the container engine and not showing help message, do preflight check to prevent parallel pull issues
    // Related issue: https://github.com/nextflow-io/nextflow/issues/1210
    if (workflow.containerEngine == 'singularity' & !params.help) {
        Singularity.singularityPreflight(workflow.container, params.singularity_cachedir, log)
    }

    // Select workflow with PIPELINE as default
    if (params.help) {
        Messages.helpMessage(log)
    } else if (params.init) {
        Messages.workflowSelectMessage('init', params, log)
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
    } else if (params.version) {
        Messages.workflowSelectMessage('version', params, log)
        PRINT_VERSION(
            params.resistance_to_mic, 
            workflow.manifest.version,
            params.db,
            params.assembler
        )
    } else {
        Messages.workflowSelectMessage('pipeline', params, log)
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
            params.resistance_to_mic,
            params.output,
            params.file_publish
        )
        SAVE_INFO(
            PIPELINE.out.databases_info, 
            params.resistance_to_mic, 
            workflow.manifest.version,
            params.assembler,
            params.assembler_thread,
            params.min_contig_length,
            params.reads,
            params.output,
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

    // End message
    workflow.onComplete = {
        if (params.help) {
            return
        } else if (params.init) {
            Messages.endMessage('init', params, workflow, log)
        } else if (params.version) {
            Messages.endMessage('version', params, workflow, log)
        } else {
            Messages.endMessage('pipeline', params, workflow, log)
        }
    }
}

