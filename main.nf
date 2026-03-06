#!/usr/bin/env nextflow


// Import workflow modules
include { PIPELINE } from './workflows/pipeline'
include { INIT } from './workflows/init'
include { PRINT_VERSION; SAVE_INFO } from './workflows/info_and_version'


workflow {
    main:
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
        Messages.workflowSelectMessage('init', params.reads, workflow.outputDir.toString(), log)
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
        Messages.workflowSelectMessage('version', params.reads, workflow.outputDir.toString(), log)
        PRINT_VERSION(
            params.resistance_to_mic, 
            workflow.manifest.version,
            params.db,
            params.assembler
        )
    } else {
        Messages.workflowSelectMessage('pipeline', params.reads, workflow.outputDir.toString(), log)
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

    // End message
    workflow.onComplete = {
        if (params.help) {
            return
        } else {
            Messages.endMessage(params.init ? 'init' : (params.version ? 'version' : 'pipeline'), workflow.outputDir.toString(), workflow, log)
        }
    }

    publish:
    overall_report  = (params.init || params.help || params.version) ? channel.empty() : PIPELINE.out.overall_report
    info            = (params.init || params.help || params.version) ? channel.empty() : SAVE_INFO.out.info
    assemblies      = (params.init || params.help || params.version) ? channel.empty() : PIPELINE.out.assemblies
    annotations     = (params.init || params.help || params.version) ? channel.empty() : PIPELINE.out.annotations
}

output {
    overall_report {
    }
    info {
    }
    assemblies {
        path 'assemblies'
    }
    annotations {
        path 'annotations'
    }
}