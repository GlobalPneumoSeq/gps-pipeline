# Check if ARIBA database was prepared from the specific reference sequences and metadata.
# Check if all files exist and data integrity is not compromised
# If not: remove the $DB_LOCAL directory, and prepare the ARIBA database from reference sequences and metadata, also save metadata to JSON

REF_SEQUENCES_MD5=$(md5sum "$REF_SEQUENCES" | awk '{ print $1 }')
METADATA_MD5=$(md5sum "$METADATA" | awk '{ print $1 }')

if  [ ! -f "${DB_LOCAL}/${JSON_FILE}" ] || \
    [ ! "$(grep '"reference"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$REF_SEQUENCES" ] || \
    [ ! "$(grep '"reference_md5"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$REF_SEQUENCES_MD5" ] || \
    [ ! "$(grep '"metadata"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$METADATA" ] || \
    [ ! "$(grep '"metadata_md5"' "${DB_LOCAL}/${JSON_FILE}" | sed -r 's/.+: "(.*)",?/\1/')" == "$METADATA_MD5" ] || \
    [ ! -f "${DB_LOCAL}/${CHECKSUM_FILE}" ] || \
    ! ( cd "${DB_LOCAL}" && md5sum -c "${CHECKSUM_FILE}" ) ; then

    rm -rf "${DB_LOCAL}"
    
    ariba prepareref -f "$REF_SEQUENCES" -m "$METADATA" "${DB_LOCAL}"

    ( cd "${DB_LOCAL}" && find . -type f -not -name "${CHECKSUM_FILE}" -exec md5sum "{}" + ) > "${DB_LOCAL}/${CHECKSUM_FILE}"

    echo -e "{\n  \"reference\": \"$REF_SEQUENCES\",\n  \"reference_md5\": \"$REF_SEQUENCES_MD5\",\n  \"metadata\": \"$METADATA\",\n  \"metadata_md5\": \"$METADATA_MD5\",\n  \"create_time\": \"$(date +"%Y-%m-%d %H:%M:%S %Z")\"\n}" > "${DB_LOCAL}/${JSON_FILE}"

fi
