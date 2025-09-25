# Return PopPUNK External Clusters file name

# Check if external clusters file was obtained from the specific link.
# Check if all files exist and data integrity is not compromised
# If not: remove the $EXT_CLUSTERS_LOCAL directory, and re-download, also save metadata to JSON

EXT_CLUSTERS_CSV=$(basename "$EXT_CLUSTERS_REMOTE")

if  [ ! -f "${EXT_CLUSTERS_LOCAL}/${JSON_FILE}" ] || \
    [ ! "$EXT_CLUSTERS_REMOTE" == "$(jq -r .url "${EXT_CLUSTERS_LOCAL}/${JSON_FILE}")"  ] || \
    [ ! -f "${EXT_CLUSTERS_LOCAL}/${CHECKSUM_FILE}" ] || \
    ! ( cd "${EXT_CLUSTERS_LOCAL}" && md5sum -c "${CHECKSUM_FILE}" ) ; then

    rm -rf "${EXT_CLUSTERS_LOCAL}"

    mkdir -p "${EXT_CLUSTERS_LOCAL}"
    wget "$EXT_CLUSTERS_REMOTE" -O "${EXT_CLUSTERS_LOCAL}/${EXT_CLUSTERS_CSV}"

    ( cd "${EXT_CLUSTERS_LOCAL}" && find . -type f -not -name "${CHECKSUM_FILE}" -exec md5sum "{}" + ) > "${EXT_CLUSTERS_LOCAL}/${CHECKSUM_FILE}"

    jq -n \
        --arg url "$EXT_CLUSTERS_REMOTE" \
        --arg save_time "$(date +"%Y-%m-%d %H:%M:%S %Z")" \
        '{"url" : $url, "save_time": $save_time}' > "${EXT_CLUSTERS_LOCAL}/${JSON_FILE}"

fi
