// Start message
void startMessage(String pipelineVersion) {
    log.info( 
        $/
        |
        |╔══════════════════════════════════════════════════════════════════════════════════════════╗
        |║                                                                                          ║░
        |║    ██████╗ ██████╗ ███████╗    ██████╗ ██╗██████╗ ███████╗██╗     ██╗███╗   ██╗███████╗  ║░
        |║   ██╔════╝ ██╔══██╗██╔════╝    ██╔══██╗██║██╔══██╗██╔════╝██║     ██║████╗  ██║██╔════╝  ║░
        |║   ██║  ███╗██████╔╝███████╗    ██████╔╝██║██████╔╝█████╗  ██║     ██║██╔██╗ ██║█████╗    ║░
        |║   ██║   ██║██╔═══╝ ╚════██║    ██╔═══╝ ██║██╔═══╝ ██╔══╝  ██║     ██║██║╚██╗██║██╔══╝    ║░
        |║   ╚██████╔╝██║     ███████║    ██║     ██║██║     ███████╗███████╗██║██║ ╚████║███████╗  ║░
        |║    ╚═════╝ ╚═╝     ╚══════╝    ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝  ║░
        |${String.format('║  v %-86s║░', pipelineVersion)}
        |╚══════════════════════════════════════════════════════════════════════════════════════════╝░
        |  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
       /$.stripMargin()
    )
}

// Help message
void helpMessage() {
    log.info(
        '''
        |This is a Nextflow Pipeline for processing Streptococcus pneumoniae sequencing raw reads (FASTQ files)
        |
        |Usage:
        |./run_pipeline [option] [value]
        |
        |All options are optional, some common options:
        |--reads [PATH]    Path to the input directory that contains the reads to be processed
        |--output [PATH]   Path to the output directory that save the results
        |--init          Alternative workflow for initialisation
        |--version       Alternative workflow for getting versions of pipeline, container images, tools and databases
        |
        |For all available options, please refer to README.md
        '''.stripMargin()
    )
}

// Workflow selection message
void workflowSelectMessage(String selectedWorkflow) {
    String message
    File readsDir = new File(params.reads)
    File outputDir = new File(params.output)

    switch (selectedWorkflow) {
        case 'pipeline':
            message = """
            |The main pipeline workflow has been selected.
            |
            |Input Directory: ${readsDir.canonicalPath}
            |Output Directory: ${outputDir.canonicalPath}
            """.stripMargin()
            break
        case 'init':
            message = '''
            |The alternative workflow for initialisation has been selected.
            '''.stripMargin()
            break
        case 'version':
            message = '''
            |The alternative workflow for getting versions of pipeline, tools and databases has been selected.
            '''.stripMargin()
            break
    }

    Date date = new Date()
    String dateStr = date.format('yyyy-MM-dd')
    String timeStr = date.format('HH:mm:ss z')

    log.info(
        """
        |${message}
        |The workflow started at ${dateStr} ${timeStr}.
        |
        |Current Progress:
        """.stripMargin()
    )
}

// End message
void endMessage(String selectedWorkflow) {
    String successMessage
    String failMessage
    File outputDir = new File(params.output)

    switch (selectedWorkflow) {
        case 'pipeline':
            successMessage = """
                |The pipeline has been completed successfully.
                |The output is located at ${outputDir.canonicalPath}.
                """.stripMargin()
            failMessage = '''
                |The pipeline has failed.
                |If you think it is caused by a bug, submit an issue at \"https://github.com/GlobalPneumoSeq/gps-pipeline/issues\".
                '''.stripMargin()
            break
        case 'init':
            successMessage = '''
                |Initialisation has been completed successfully.
                |The pipeline can now be used offline (unless you have changed the selection of any database or container image).
                '''.stripMargin()
            failMessage = '''
                |Initialisation has failed.
                |Please ensure Container Engine (i.e. Docker or Singularity) is running and your machine is conneted to the Internet.
                '''.stripMargin()
            break
        case 'version':
            successMessage = '''
                |All the version information is printed above.
                '''.stripMargin()
            failMessage = '''
                |Failed to get version information on pipeline, tools or databases.
                |If you think it is caused by a bug, submit an issue at \"https://github.com/GlobalPneumoSeq/gps-pipeline/issues\"
                '''.stripMargin()
            break
    }

    Date date = new Date()
    String dateStr = date.format('yyyy-MM-dd')
    String timeStr = date.format('HH:mm:ss z')

    log.info(
        """
        |The workflow ended at ${dateStr} ${timeStr}. The duration was ${workflow.duration}
        |${workflow.success ? successMessage : failMessage}
        """.stripMargin()
    )
}
