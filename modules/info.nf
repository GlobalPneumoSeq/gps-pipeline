// Extract containers information of workflow and save into a JSON file
process IMAGES {
    label 'bash_container'
    label 'farm_low'

    input:
    path processesContainersList

    output:
    path(json), emit: json

    script:
    json='images.json'
    """
    PROCESSES_CONTAINERS_LIST="$processesContainersList"
    JSON_FILE="$json"

    source save_images_info.sh
    """
}

// Save received databases information into a JSON file
process DATABASES {
    label 'bash_container'
    label 'farm_low'

    input:
    path bwa_db_path
    path ariba_db_path
    path kraken2_db_path
    path seroba_db_path
    path poppunk_db_path
    path poppunk_ext_path
    path bakta_db_path
    path resistance_to_mic

    output:
    path(json), emit: json

    script:
    json='databases.json'
    bwa_json='done_bwa_db.json'
    ariba_json='done_ariba_db.json'
    seroba_json='done_seroba.json'
    kraken2_json='done_kraken.json'
    poppunk_json='done_poppunk.json'
    poppunk_ext_json='done_poppunk_ext.json'
    bakta_json='done_bakta.json'
    """
    BWA_DB_PATH="$bwa_db_path"
    BWA_JSON="$bwa_json"
    ARIBA_DB_PATH="$ariba_db_path"
    ARIBA_JSON="$ariba_json"
    KRAKEN2_DB_PATH="$kraken2_db_path"
    KRAKEN2_JSON="$kraken2_json"
    SEROBA_DB_PATH="$seroba_db_path"
    SEROBA_JSON="$seroba_json"
    POPPUNK_DB_PATH="$poppunk_db_path"
    POPPUNK_JSON="$poppunk_json"
    POPPUNK_EXT_PATH="$poppunk_ext_path"
    POPPUNK_EXT_JSON="$poppunk_ext_json"
    BAKTA_DB_PATH="$bakta_db_path"
    BAKTA_JSON="$bakta_json"
    RESISTANCE_TO_MIC="$resistance_to_mic"
    JSON_FILE="$json"

    source save_databases_info.sh
    """
}

// Save received tools versions into a JSON file
process TOOLS {
    label 'bash_container'
    label 'farm_low'

    input:
    val python_version
    val fastp_version
    tuple  val(unicycler_version), val(unicycler_nproc_value)
    tuple  val(shovill_version), val(shovill_nproc_value)
    val quast_version
    val bwa_version
    val samtools_version
    val bcftools_version
    val poppunk_version
    val mlst_version
    val kraken2_version
    val seroba_version
    val ariba_version
    val bakta_version

    output:
    path(json), emit: json

    script:
    json='tools.json'
    """
    PYTHON_VERSION="$python_version"
    FASTP_VERSION="$fastp_version"
    UNICYCLER_VERSION="$unicycler_version"
    UNICYCLER_NPROC_VALUE="$unicycler_nproc_value"
    SHOVILL_VERSION="$shovill_version"
    SHOVILL_NPROC_VALUE="$shovill_nproc_value"
    QUAST_VERSION="$quast_version"
    BWA_VERSION="$bwa_version"
    SAMTOOLS_VERSION="$samtools_version"
    BCFTOOLS_VERSION="$bcftools_version"
    POPPUNK_VERSION="$poppunk_version"
    MLST_VERSION="$mlst_version"
    KRAKEN2_VERSION="$kraken2_version"
    SEROBA_VERSION="$seroba_version"
    ARIBA_VERSION="$ariba_version"
    BAKTA_VERSION="$bakta_version"
    JSON_FILE="$json"
                
    source save_tools_info.sh
    """
}

// Combine pipeline version, Nextflow version, databases information, container images, tools version JSON files into the a single JSON file
process COMBINE_INFO {
    label 'bash_container'
    label 'farm_low'

    input:
    val pipeline_version
    val nextflow_version
    path database
    path images
    path tools

    output:
    path(json), emit: json

    script:
    json='result.json'
    """
    PIPELINE_VERSION="$pipeline_version"
    NEXTFLOW_VERSION="$nextflow_version"
    DATABASE="$database"
    IMAGES="$images"
    TOOLS="$tools"
    JSON_FILE="$json"

    source save_combined_info.sh
    """
}

// Parse information from JSON into human-readable tables
process PARSE {
    label 'farm_local'

    input:
    val json_file
    val assembler

    output:
    tuple val(coreText), val(dbText), val(toolText), val(imageText), val(nprocValue), emit: text

    exec:
    def jsonSlurper = new groovy.json.JsonSlurper()

    def json = jsonSlurper.parse(new File("${json_file}"))

    if (assembler == 'unicycler') {
        nprocValue = json.unicycler.nproc_value
    } else if (assembler == 'shovill') {
        nprocValue = json.shovill.nproc_value
    }

    coreText = """\
        |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Core Software Versions ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
        |╔═══════════════════════════╤═════════════════════════════════════════════════════════════════════╗
        |${Texts.coreTextRow('Software', 'Version')}
        |╠═══════════════════════════╪═════════════════════════════════════════════════════════════════════╣
        |${Texts.coreTextRow('GPS Pipeline', json.pipeline.version)}
        |${Texts.coreTextRow('Nextflow', json.nextflow.version)}
        |╚═══════════════════════════╧═════════════════════════════════════════════════════════════════════╝
        |""".stripMargin()

    dbText = """\
        |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Databases Information ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
        |╔═════════════════════════════════════════════════════════════════════════════════════════════════╗
        |║ BWA reference genome FM-index database                                                          ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Reference', json.bwa_db.reference)}
        |${Texts.dbTextRow('Reference MD5', json.bwa_db.reference_md5)}
        |${Texts.dbTextRow('Created', json.bwa_db.create_time)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ Kraken 2 database                                                                               ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Source', json.kraken2_db.url)}
        |${Texts.dbTextRow('Saved', json.kraken2_db.save_time)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ PopPUNK database                                                                                ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Source', json.poppunnk_db.url)}
        |${Texts.dbTextRow('Saved', json.poppunnk_db.save_time)}
        |${Texts.dbTextRow('Version', json.poppunnk_db.db_version)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ PopPUNK external clusters file                                                                  ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Source', json.poppunk_ext.url)}
        |${Texts.dbTextRow('Saved', json.poppunk_ext.save_time)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ SeroBA database                                                                                 ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Source', json.seroba_db.url)}
        |${Texts.dbTextRow('Kmer size', json.seroba_db.kmer)}
        |${Texts.dbTextRow('Created', json.seroba_db.create_time)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ ARIBA database                                                                                  ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Reference', json.ariba_db.reference)}
        |${Texts.dbTextRow('Reference MD5', json.ariba_db.reference_md5)}
        |${Texts.dbTextRow('Metadata', json.ariba_db.metadata)}
        |${Texts.dbTextRow('Metadata MD5', json.ariba_db.metadata_md5)}
        |${Texts.dbTextRow('Created', json.ariba_db.create_time)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ Resistance phenotypes to MIC (minimum inhibitory concentration) lookup table                    ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Table', json.resistance_to_mic.table)}
        |${Texts.dbTextRow('Table MD5', json.resistance_to_mic.table_md5)}
        |╠═══════════════╧═════════════════════════════════════════════════════════════════════════════════╣
        |║ Bakta database                                                                                  ║
        |╟───────────────┬─────────────────────────────────────────────────────────────────────────────────╢
        |${Texts.dbTextRow('Source', json.bakta_db.url)}
        |${Texts.dbTextRow('Saved', json.bakta_db.save_time)}
        |${Texts.dbTextRow('Version', json.bakta_db.db_version)}
        |╚═══════════════╧═════════════════════════════════════════════════════════════════════════════════╝
        |""".stripMargin()

    toolText = """\
        |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Tool Versions ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
        |╔════════════════════════════════╤════════════════════════════════════════════════════════════════╗
        |${Texts.textRow(30, 62, 'Tool', 'Version')}
        |╠════════════════════════════════╪════════════════════════════════════════════════════════════════╣
        |${Texts.toolTextRow(json, 'Python', 'python')}
        |${Texts.toolTextRow(json, 'fastp', 'fastp')}
        |${Texts.toolTextRow(json, 'Unicycler', 'unicycler')}
        |${Texts.toolTextRow(json, 'Shovill', 'shovill')}
        |${Texts.toolTextRow(json, 'QUAST', 'quast')}
        |${Texts.toolTextRow(json, 'BWA', 'bwa')}
        |${Texts.toolTextRow(json, 'SAMtools', 'samtools')}
        |${Texts.toolTextRow(json, 'BCFtools', 'bcftools')}
        |${Texts.toolTextRow(json, 'PopPUNK', 'poppunk')}
        |${Texts.toolTextRow(json, 'CDC PBP AMR Predictor', 'spn_pbp_amr')}
        |${Texts.toolTextRow(json, 'ARIBA', 'ariba')}
        |${Texts.toolTextRow(json, 'mlst', 'mlst')}
        |${Texts.toolTextRow(json, 'Kraken 2', 'kraken2')}
        |${Texts.toolTextRow(json, 'SeroBA', 'seroba')}
        |${Texts.toolTextRow(json, 'Bakta', 'bakta')}
        |╚════════════════════════════════╧════════════════════════════════════════════════════════════════╝
        |""".stripMargin()

    imageText = """\
        |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Container Images ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
        |╔════════════════════════════════╤════════════════════════════════════════════════════════════════╗
        |${Texts.textRow(30, 62, 'Environment For', 'Image')}
        |╠════════════════════════════════╪════════════════════════════════════════════════════════════════╣
        |${Texts.imageTextRow(json, 'Bash', 'bash')}
        |${Texts.imageTextRow(json, 'Python', 'python')}
        |${Texts.imageTextRow(json, 'fastp', 'fastp')}
        |${Texts.imageTextRow(json, 'Unicycler', 'unicycler')}
        |${Texts.imageTextRow(json, 'Shovill', 'shovill')}
        |${Texts.imageTextRow(json, 'QUAST', 'quast')}
        |${Texts.imageTextRow(json, 'BWA', 'bwa')}
        |${Texts.imageTextRow(json, 'SAMtools', 'samtools')}
        |${Texts.imageTextRow(json, 'BCFtools', 'bcftools')}
        |${Texts.imageTextRow(json, 'PopPUNK', 'poppunk')}
        |${Texts.imageTextRow(json, 'CDC PBP AMR Predictor', 'spn_pbp_amr')}
        |${Texts.imageTextRow(json, 'ARIBA', 'ariba')}
        |${Texts.imageTextRow(json, 'mlst', 'mlst')}
        |${Texts.imageTextRow(json, 'Kraken 2', 'kraken2')}
        |${Texts.imageTextRow(json, 'SeroBA', 'seroba')}
        |${Texts.imageTextRow(json, 'Bakta', 'bakta')}
        |╚════════════════════════════════╧════════════════════════════════════════════════════════════════╝
        |""".stripMargin()
}

// Print parsed version information
process PRINT {
    label 'farm_local'

    input:
    tuple val(coreText), val(dbText), val(toolText), val(imageText), val(nprocValue)

    exec:
    log.info(
        """
        |╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
        |╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍ Version Information ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
        |╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
        |
        |${coreText}
        |${dbText}
        |${toolText}
        |${imageText}
        |""".stripMargin()
    )
}

// Save core software, I/O, assembler, QC parameters, databases, tools, container engine and images information to info.txt at output dir
process SAVE {
    label 'farm_local'
    
    publishDir "${output}", mode: "copy"

    input:
    tuple val(coreText), val(dbText), val(toolText), val(imageText), val(nprocValue)
    val reads
    val output
    val assembler
    val assembler_thread
    val min_contig_length
    val contigs
    val length_low
    val length_high
    val depth
    val spneumo_percentage
    val non_strep_percentage
    val ref_coverage
    val het_snp_site

    output:
    path "info.txt", emit: info

    exec:
    File readsDir = new File(reads)
    File outputDir = new File(output)

    String ioText = """\
    |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Input and Output ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
    |╔══════════╤══════════════════════════════════════════════════════════════════════════════════════╗
    |${Texts.ioTextRow('Type', 'Path')}
    |╠══════════╪══════════════════════════════════════════════════════════════════════════════════════╣
    |${Texts.ioTextRow('Input', readsDir.canonicalPath)}
    |${Texts.ioTextRow('Output', outputDir.canonicalPath)}
    |╚══════════╧══════════════════════════════════════════════════════════════════════════════════════╝
    |""".stripMargin()

    String assemblerText = """\
    |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Assembler Options ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
    |╔═══════════════════════════╤═════════════════════════════════════════════════════════════════════╗
    |${Texts.assemblerTextRow('Option', 'Value')}
    |╠═══════════════════════════╪═════════════════════════════════════════════════════════════════════╣
    |${Texts.assemblerTextRow('Assembler', assembler.capitalize())}
    |${Texts.assemblerTextRow('Assembler Thread', assembler_thread == 0 ? "${nprocValue} (All Available)" : assembler_thread)}
    |${Texts.assemblerTextRow('Minimum contig length', min_contig_length)}
    |╚═══════════════════════════╧═════════════════════════════════════════════════════════════════════╝
    |""".stripMargin()

    String qcText = """\
    |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ QC Parameters ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
    |╔═════════════════════════════════════════════════════════════════════════════════════════════════╗
    |║ Read QC                                                                                         ║
    |╟──────────────────────────────────────────────────────────────┬──────────────────────────────────╢
    |${Texts.qcTextRow('Minimum bases in processed reads', String.format("%.0f", Math.ceil(length_low * depth)))}
    |╠══════════════════════════════════════════════════════════════╧══════════════════════════════════╣
    |║ Taxonomy QC                                                                                     ║
    |╟──────────────────────────────────────────────────────────────┬──────────────────────────────────╢
    |${Texts.qcTextRow('Minimum S. pneumoniae percentage in reads', spneumo_percentage)}
    |${Texts.qcTextRow('Maximum non-Streptococcus genus percentage in reads', non_strep_percentage)}
    |╠══════════════════════════════════════════════════════════════╧══════════════════════════════════╣
    |║ Mapping QC                                                                                      ║
    |╟──────────────────────────────────────────────────────────────┬──────────────────────────────────╢
    |${Texts.qcTextRow('Minimum reference coverage percentage by the reads', ref_coverage)}
    |${Texts.qcTextRow('Maximum non-cluster heterozygous SNP (Het-SNP) site count', het_snp_site)}
    |╠══════════════════════════════════════════════════════════════╧══════════════════════════════════╣
    |║ Assembly QC                                                                                     ║
    |╟──────────────────────────────────────────────────────────────┬──────────────────────────────────╢
    |${Texts.qcTextRow('Maximum contig count in assembly', contigs)}
    |${Texts.qcTextRow('Minimum assembly length', length_low)}
    |${Texts.qcTextRow('Maximum assembly length', length_high)}
    |${Texts.qcTextRow('Minimum sequencing depth', depth)}
    |╚══════════════════════════════════════════════════════════════╧══════════════════════════════════╝
    |""".stripMargin()

    String containerEngineText = """\
    |┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ Container Engine Options ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
    |╔═══════════════════════════╤═════════════════════════════════════════════════════════════════════╗
    |${Texts.containerEngineTextRow('Option', 'Value')}
    |╠═══════════════════════════╪═════════════════════════════════════════════════════════════════════╣
    |${Texts.containerEngineTextRow('Container Engine', workflow.containerEngine.capitalize())}
    |╚═══════════════════════════╧═════════════════════════════════════════════════════════════════════╝
    |""".stripMargin()

    File info_file = new File("${task.workDir}/info.txt")
    info_file.write(
        """\
        |${coreText}
        |${ioText}
        |${assemblerText}
        |${qcText}
        |${dbText}
        |${toolText}
        |${containerEngineText}
        |${imageText}
        |""".stripMargin()
    )
}

// Below processes get tool versions within container images by running their containers

process PYTHON_VERSION {
    label 'python_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(python3 --version | sed -r "s/^.*[[:space:]]//")
    '''
}

process FASTP_VERSION {
    label 'fastp_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(fastp -v 2>&1 | sed -r "s/^.*[[:space:]]//")
    '''
}

process UNICYCLER_VERSION {
    label 'unicycler_container'
    label 'farm_high'

    output:
    tuple env('VERSION'), env('THREAD')

    script:
    '''
    VERSION=$(unicycler --version | sed -r "s/^.*[[:space:]]v//")
    THREAD=$(nproc)
    '''
}

process SHOVILL_VERSION {
    label 'shovill_container'
    label 'farm_high'

    output:
    tuple env('VERSION'), env('THREAD')

    script:
    '''
    VERSION=$(shovill -v | sed -r "s/^.*[[:space:]]//")
    THREAD=$(nproc)
    '''
}

process QUAST_VERSION {
    label 'quast_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(quast.py -v | sed -r "s/^.*[[:space:]]v//")
    '''
}

process BWA_VERSION {
    label 'bwa_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(bwa 2>&1 | grep Version | sed -r "s/^.*:[[:space:]]//")
    '''
}

process SAMTOOLS_VERSION {
    label 'samtools_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(samtools 2>&1 | grep Version | sed -r -e "s/^.*:[[:space:]]//" -e "s/[[:space:]].+$//")
    '''
}

process BCFTOOLS_VERSION {
    label 'bcftools_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(bcftools 2>&1 | grep Version | sed -r -e "s/^.*:[[:space:]]//" -e "s/[[:space:]].+$//")
    '''
}

process POPPUNK_VERSION {
    label 'poppunk_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(poppunk --version | sed -r "s/^.*[[:space:]]//")
    '''
}

process MLST_VERSION {
    label 'mlst_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(mlst -v | sed -r "s/.*[[:space:]]//")
    '''
}

process KRAKEN2_VERSION {
    label 'kraken2_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(kraken2 -v | grep version | sed -r "s/.*[[:space:]]//")
    '''
}

process SEROBA_VERSION {
    label 'seroba_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(seroba version)
    '''
}

process ARIBA_VERSION {
    label 'ariba_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(ariba version | grep ARIBA | sed -r "s/.*:[[:space:]]//")
    '''
}

process BAKTA_VERSION {
    label 'bakta_container'
    label 'farm_low'

    output:
    env 'VERSION'

    script:
    '''
    VERSION=$(bakta --version | sed -r "s/^.*[[:space:]]//")
    '''
}
