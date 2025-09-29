# Return Bakta database name

# Check if database was obtained from the database at the specific link.
# Check if all files exist and data integrity is not compromised
# If not: remove all sub-directories, download, and unzip to database directory, also save metadata to JSON

ZIPPED_DB='bakta_db.tar.xz'

if  [ ! -f "${DB_LOCAL}/${JSON_FILE}" ] || \
    [ ! "$DB_REMOTE" == "$(jq -r .url "${DB_LOCAL}/${JSON_FILE}")" ] || \
    [ ! -f "${DB_LOCAL}/${CHECKSUM_FILE}" ] || \
    ! ( cd "${DB_LOCAL}" && md5sum -c "${CHECKSUM_FILE}" ) ; then

    rm -rf "${DB_LOCAL}"

    wget "${DB_REMOTE}" -O $ZIPPED_DB
    mkdir -p "${DB_LOCAL}"
    tar -xJf $ZIPPED_DB --strip-components=1 -C "${DB_LOCAL}"
    rm $ZIPPED_DB

    ( cd "${DB_LOCAL}" && find . -type f -not -name "${CHECKSUM_FILE}" -exec md5sum "{}" + ) > "${DB_LOCAL}/${CHECKSUM_FILE}"

    DB_VERSION=$(< ${DB_LOCAL}/version.json jq -r '"\(.major).\(.minor) \(.type)"')

    jq -n \
        --arg url "$DB_REMOTE" \
        --arg db_version "$DB_VERSION" \
        --arg save_time "$(date +"%Y-%m-%d %H:%M:%S %Z")" \
        '{"url" : $url, "db_version": $db_version, "save_time": $save_time}' > "${DB_LOCAL}/${JSON_FILE}"

fi
