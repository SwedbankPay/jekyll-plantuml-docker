#!/bin/bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage: echo $me <version>

Generates variables based on the provided environment variable GITHUB_CONTEXT
and <version> argument.

GITHUB_CONTEXT: An environment variable containing a JSON string of the GitHub
                context object. Typically generated with \${{ toJson(github) }}.
     <version>: The version number corresponding to the current Git commit."

initialize() {
    github_context_json="$GITHUB_CONTEXT"
    version="$1"

    if [[ -z "$github_context_json" ]]; then
        echo "Missing or empty GITHUB_CONTEXT environment variable." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$version" ]]; then
        echo "No version specified." >&2
        echo "$help_message"
        exit 1
    fi

    sha=$(echo "$github_context_json" | jq --raw-output .sha)
    ref=$(echo "$github_context_json" | jq --raw-output .ref)
    run_id=$(echo "$github_context_json" | jq --raw-output .run_id)
    run_number=$(echo "$github_context_json" | jq --raw-output .run_number)

    if [[ -z "$sha" ]]; then
        echo "No 'sha' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$ref" ]]; then
        echo "No 'ref' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$run_id" ]]; then
        echo "No 'run_id' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ -z "$run_number" ]]; then
        echo "No 'run_number' found in the GitHub context." >&2
        echo "$help_message"
        exit 1
    fi
}

generate_variables() {
    # Replace + in the version number with a dot.
    version="${version/+/.}"
    sha8=$(echo "${sha}" | cut -c1-8)
    date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

    # Override GitVersion's version on tags, just to be sure.
    if [[ "$ref" == refs/tags/* ]]; then
        version="${ref#refs/tags/}"
    fi

    branch_name="r${run_id}-${run_number}"

    echo "Ref:     ${ref}"
    echo "Sha:     ${sha}"
    echo "Sha8:    ${sha8}"
    echo "Date:    ${date}"
    echo "Branch:  ${branch_name}"
    echo "Version: ${version}"
    echo "::set-output name=ref::${ref}"
    echo "::set-output name=sha::${sha}"
    echo "::set-output name=sha8::${sha8}"
    echo "::set-output name=date::${date}"
    echo "::set-output name=version::${version}"
    echo "::set-output name=branch_name::${branch_name}"
}

main() {
    initialize "$@"
    generate_variables
}

main "$@"
