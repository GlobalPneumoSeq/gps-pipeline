jq -s '.[0] * .[1] * .[2]' $DATABASE $IMAGES $TOOLS > working.json

add_version () {
    jq --arg entry $1 --arg version "$2" '.[$entry] += {"version": $version}' working.json > tmp.json && mv tmp.json working.json
}

add_version pipeline "$PIPELINE_VERSION"
add_version nextflow "$NEXTFLOW_VERSION"

mv working.json $JSON_FILE
