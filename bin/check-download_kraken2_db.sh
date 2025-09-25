# Check if database was obtained from the specific link.
# Check if all files exist and data integrity is not compromised
# If not: remove files in database directory, download, and unzip to database directory, also save metadata to JSON

ZIPPED_DB='kraken2_db.tar.gz'

if  [ ! -f "${DB_LOCAL}/${JSON_FILE}" ] || \
    [ ! "$DB_REMOTE" == "$(jq -r .url "${DB_LOCAL}/${JSON_FILE}")"  ] || \
    [ ! -f "${DB_LOCAL}/${CHECKSUM_FILE}" ] || \
    ! ( cd "${DB_LOCAL}" && md5sum -c "${CHECKSUM_FILE}" ) ; then

    rm -rf "${DB_LOCAL}"

    wget "${DB_REMOTE}" -O $ZIPPED_DB

    # Use tmp dir and find to ensure files are saved directly at $DB_LOCAL regardless of archive directory structure
    mkdir tmp
    tar -xzf $ZIPPED_DB -C tmp
    mkdir -p "${DB_LOCAL}"
    find tmp -type f -exec mv {} "$DB_LOCAL" \;

    rm -f $ZIPPED_DB

    ( cd "${DB_LOCAL}" && find . -type f -not -name "${CHECKSUM_FILE}" -exec md5sum "{}" + ) > "${DB_LOCAL}/${CHECKSUM_FILE}"

    jq -n \
        --arg url "${DB_REMOTE}" \
        --arg save_time "$(date +"%Y-%m-%d %H:%M:%S %Z")" \
        '{"url" : $url, "save_time": $save_time}' > "${DB_LOCAL}/${JSON_FILE}"

fi
