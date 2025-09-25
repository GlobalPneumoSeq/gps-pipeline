# Check if database was downloaded from specific link, also prepared by the specific Kmer
# Check if all files exist and data integrity is not compromised
# If not: remove files in database directory and download, re-create KMC and ARIBA databases, also save metadata to JSON

ZIPPED_REPO='seroba.tar.gz'

if  [ ! -f "${DB_LOCAL}/${JSON_FILE}" ] || \
    [ ! "$(grep '"url"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$DB_REMOTE" ] || \
    [ ! "$(grep '"kmer"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$KMER" ] || \
    [ ! -f "${DB_LOCAL}/${CHECKSUM_FILE}" ] || \
    ! ( cd "${DB_LOCAL}" && md5sum -c "${CHECKSUM_FILE}" ) ; then

    rm -rf "${DB_LOCAL}"

    wget "${DB_REMOTE}" -O $ZIPPED_REPO

    mkdir tmp
    tar -xzf $ZIPPED_REPO --strip-components=1 -C tmp

    mkdir -p "${DB_LOCAL}"
    mv tmp/database/* "${DB_LOCAL}"

    seroba createDBs "${DB_LOCAL}" "${KMER}"

    rm -f $ZIPPED_REPO

    ( cd "${DB_LOCAL}" && find . -type f -not -name "${CHECKSUM_FILE}" -exec md5sum "{}" + ) > "${DB_LOCAL}/${CHECKSUM_FILE}"

    echo -e "{\n  \"url\": \"$DB_REMOTE\",\n  \"kmer\": \"$KMER\",\n  \"create_time\": \"$(date +"%Y-%m-%d %H:%M:%S %Z")\"\n}" > "${DB_LOCAL}/${JSON_FILE}"

fi
