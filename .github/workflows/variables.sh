#!/bin/bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage: $me <sha> <ref>
Generates variables based on the provided <sha> and <ref>.

<sha>: The SHA of the curretn Git commit.
<ref>: The name of the ref of the current Git commit."

initialize() {
	sha="$1"
    ref="$2"

    if [[ -z "$sha" ]]; then
        echo "No sha specified." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$ref" ]]; then
        echo "No ref specified." >&2
        echo "$help_message"
        exit 1
    fi
}

generate_variables() {
    sha8=$(echo "${sha}" | cut -c1-8)
    date=$(date +%F)

    if [[ "$ref" == refs/tags/* ]]; then
        version="${ref#refs/tags/}"
    else
        version="$sha8"
    fi

    echo "Version: ${version}"
    echo "SHA8: ${sha8}"
    echo "Date: ${date}"
    echo "::set-output name=version::${version}"
    echo "::set-output name=sha8::${sha8}"
    echo "::set-output name=date::${date}"
}

main() {
	initialize "$@"
    generate_variables
}

main "$@"
