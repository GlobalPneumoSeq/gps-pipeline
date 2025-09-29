// Import process modules
include { GET_REF_GENOME_BWA_DB } from '../modules/mapping'
include { GET_KRAKEN2_DB } from '../modules/taxonomy'
include { GET_POPPUNK_DB; GET_POPPUNK_EXT_CLUSTERS } from '../modules/lineage'
include { GET_SEROBA_DB } from '../modules/serotype'
include { GET_DOCKER_COMPOSE; PULL_IMAGES } from '../modules/docker'
include { GET_ARIBA_DB } from '../modules/amr'
include { GET_BAKTA_DB } from '../modules/annotation'

// Alternative workflow for initialisation only
workflow INIT {
    take:
    annotation
    db
    ref_genome
    ariba_ref
    ariba_metadata
    kraken2_db_remote
    seroba_db_remote
    seroba_kmer
    poppunk_db_remote
    poppunk_ext_remote
    bakta_db_remote

    main:
    // Check Reference Genome BWA Database, generate from assembly if necessary
    GET_REF_GENOME_BWA_DB(ref_genome, db)

    // Check ARIBA database, generate from reference sequences and metadata if ncessary
    GET_ARIBA_DB(ariba_ref, ariba_metadata, db)

    // Check Kraken2 Database, download if necessary
    GET_KRAKEN2_DB(kraken2_db_remote, db)

    // Check SeroBA Databases, download and rebuild if necessary
    GET_SEROBA_DB(seroba_db_remote, db, seroba_kmer)

    // Check PopPUNK Database and External Clusters, download if necessary
    GET_POPPUNK_DB(poppunk_db_remote, db)
    GET_POPPUNK_EXT_CLUSTERS(poppunk_ext_remote, db)

    // Check Bakta database, download if necessary
    if (annotation) {
        GET_BAKTA_DB(bakta_db_remote, db)
    }

    // Pull all Docker images used in the workflow if using Docker
    if (workflow.containerEngine == 'docker') {
        GET_DOCKER_COMPOSE(
            Channel.fromList(workflow.container.collect { it.value })
                .unique()
                .collectFile(name: 'containersList.txt', newLine: true)
        )
        
        PULL_IMAGES(GET_DOCKER_COMPOSE.out.compose)
    }
}
