// Return Bakta database path, download and create database if necessary
process GET_BAKTA_DB {
    label 'bash_container'
    label 'farm_low'
    label 'farm_scratchless'
    label 'farm_slow'

    input: 
    val db_remote
    path db

    output:
    path bakta_db, emit: path

    script:
    bakta_db="${db}/bakta"
    json='done_bakta.json'
    checksum='checksum.md5'
    """
    DB_REMOTE="$db_remote"
    DB_LOCAL="$bakta_db"
    JSON_FILE="$json"
    CHECKSUM_FILE='$checksum'

    source check-download_bakta_db.sh
    """
}

// Run Bakta to get annotation
// Publish the annotation to ${output}/annotations directory based on ${file_publish}
process ANNOTATE {
    label 'bakta_container'
    label 'farm_high'
    
    tag "$sample_id"

    publishDir "${output}/annotations", mode: "${file_publish}"

    input:
    path bakta_db
    tuple val(sample_id), path(assembly)
    val output
    val file_publish
    
    output:
    tuple val(sample_id), path(gff)

    script:
    gff="${sample_id}.gff3"
    """
    bakta --db "$bakta_db" --prefix "$sample_id" --skip-plot --genus Streptococcus --species pneumoniae "$assembly"
    """
}
