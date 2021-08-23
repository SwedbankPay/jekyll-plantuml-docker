#!/usr/bin/env bash

set -o errexit #abort if any command fails
me=$(basename "$0")
help_message="\
Usage:
  $me [--verbose]
  $me --help
Arguments:
  -h, --help                    Displays this help screen
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        else
            break
        fi
    done
}

enable_expanded_output() {
    # Echo expanded commands as they are executed (for debugging)
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

main() {
    parse_args "$@"

    enable_expanded_output

    [ $verbose ] && find . # Output the diretory tree if $verbose

    JSON=$(cat apt.json)

    for PACKAGE in $(echo "$JSON" | jq -r 'keys | .[]'); do
        VERSION=$(apt-cache policy "$PACKAGE" | grep -oP '(?<=Candidate:\s)(.+)')
        echo "Updating '$PACKAGE' to version $VERSION."
        JSON=$(echo "$JSON" | jq '.[$package] = $version' --arg package "$PACKAGE" --arg version "$VERSION")
    done

    echo "Writing apt.json to disk:"
    echo "$JSON"
    echo "$JSON" | python -m json.tool > apt.json
}

main "$@"
