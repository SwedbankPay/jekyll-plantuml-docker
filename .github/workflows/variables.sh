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
    version="$3"

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

    if [[ -z "$version" ]]; then
        echo "No version specified." >&2
        echo "$help_message"
        exit 1
    fi
}

generate_variables() {
    sha8=$(echo "${sha}" | cut -c1-8)
    date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

    # Override GitVersion's version on tags, just to be sure.
    if [[ "$ref" == refs/tags/* ]]; then
        version="${ref#refs/tags/}"
    fi

    echo "Ref:     ${ref}"
    echo "Sha:     ${sha}"
    echo "Sha8:    ${sha8}"
    echo "Date:    ${date}"
    echo "Version: ${version}"
    echo "::set-output name=ref::${ref}"
    echo "::set-output name=sha::${sha}"
    echo "::set-output name=sha8::${sha8}"
    echo "::set-output name=date::${date}"
    echo "::set-output name=version::${version}"
}

main() {
	initialize "$@"
    generate_variables
}

main "$@"
