include { IMAGES; DATABASES; TOOLS; COMBINE_INFO; PARSE; PRINT; SAVE; PYTHON_VERSION; FASTP_VERSION; UNICYCLER_VERSION; SHOVILL_VERSION; QUAST_VERSION; BWA_VERSION; SAMTOOLS_VERSION; BCFTOOLS_VERSION; POPPUNK_VERSION; MLST_VERSION; KRAKEN2_VERSION; SEROBA_VERSION; ARIBA_VERSION; BAKTA_VERSION} from '../modules/info'

// Alternative workflow that prints versions of pipeline and tools
workflow PRINT_VERSION {
    take:
        resistance_to_mic
        pipeline_version
        db
        assembler

    main:
        GET_VERSION(
            "${db}/bwa",
            "${db}/ariba",
            "${db}/kraken2",
            "${db}/seroba",
            "${db}/poppunk",
            "${db}/poppunk_ext",
            "${db}/bakta",
            resistance_to_mic,
            pipeline_version
        )
        
        PARSE(
            GET_VERSION.out.json,
            assembler
        )
        
        PRINT(PARSE.out.text)
}

// Sub-workflow of PIPELINE workflow the save versions of pipeline and tools, and QC parameters to info.txt at output dir
workflow SAVE_INFO {
    take:
        databases_info
        resistance_to_mic
        pipeline_version
        assembler
        assembler_thread
        min_contig_length
        reads
        output
        contigs
        length_low
        length_high
        depth
        spneumo_percentage
        non_strep_percentage
        ref_coverage
        het_snp_site


    main:
        GET_VERSION(
            databases_info.bwa_db_path,
            databases_info.ariba_db_path,
            databases_info.kraken2_db_path,
            databases_info.seroba_db_path,
            databases_info.poppunk_db_path,
            databases_info.poppunk_ext_path,
            databases_info.bakta_db_path,
            resistance_to_mic,
            pipeline_version
        )

       PARSE(
            GET_VERSION.out.json,
            assembler
        )
       
       SAVE(
            PARSE.out.text,
            reads,
            output,
            assembler,
            assembler_thread,
            min_contig_length,
            contigs,
            length_low,
            length_high,
            depth,
            spneumo_percentage,
            non_strep_percentage,
            ref_coverage,
            het_snp_site
        )
}

// Sub-workflow for generating a json that contains versions of pipeline and tools
workflow GET_VERSION {
    take:
        bwa_db_path
        ariba_db_path
        kraken2_db_path
        seroba_db_path
        poppunk_db_path
        poppunk_ext_path
        bakta_db_path
        resistance_to_mic
        pipeline_version

    main:
        IMAGES(
            Channel.fromList(workflow.container.collect { "${it.key}\t${it.value}" })
                .unique()
                .collectFile(name: 'processesContainersList.tsv', newLine: true)
        )            

        DATABASES(
            bwa_db_path,
            ariba_db_path,
            kraken2_db_path,
            seroba_db_path,
            poppunk_db_path,
            poppunk_ext_path,
            bakta_db_path,
            resistance_to_mic
        )

        nextflow_version = "$nextflow.version"

        PYTHON_VERSION()
        FASTP_VERSION()
        UNICYCLER_VERSION()
        SHOVILL_VERSION()
        QUAST_VERSION()
        BWA_VERSION()
        SAMTOOLS_VERSION()
        BCFTOOLS_VERSION()
        POPPUNK_VERSION()
        MLST_VERSION()
        KRAKEN2_VERSION()
        SEROBA_VERSION()
        ARIBA_VERSION()
        BAKTA_VERSION()

        TOOLS(
            PYTHON_VERSION.out,
            FASTP_VERSION.out,
            UNICYCLER_VERSION.out,
            SHOVILL_VERSION.out,
            QUAST_VERSION.out,
            BWA_VERSION.out,
            SAMTOOLS_VERSION.out,
            BCFTOOLS_VERSION.out,
            POPPUNK_VERSION.out,
            MLST_VERSION.out,
            KRAKEN2_VERSION.out,
            SEROBA_VERSION.out,
            ARIBA_VERSION.out,
            BAKTA_VERSION.out
        )

        COMBINE_INFO(
            pipeline_version,
            nextflow_version,
            DATABASES.out.json,
            IMAGES.out.json,
            TOOLS.out.json
        )

    emit:
        json = COMBINE_INFO.out.json
}
