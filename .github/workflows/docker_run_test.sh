#!/bin/bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage: $me <jekyll-command>
Execute <jekyll-command> in the Docker container and optionally test the output.

<jekyll-command>: The Jekyll command to execute. Supported commands:
           build: Builds and returns the exit code from the build.
           serve: Serves and searches for 'Server running...' in the output
                  generated by Jekyll. Exits successfully if the output can be
                  found, otherwise fails."

initialize() {
	docker_tag=${TAG:-latest}
    docker_image_name=${IMAGE_NAME:-"swedbankpay/jekyll-plantuml"}
	local_directory=${JEKYLL_DIR:-"$PWD"}
    input_command="$1"

    if [[ -z "$input_command" ]]; then
        echo "No command specified." >&2
        echo "$help_message"
        exit 1
    fi

    if [[ "$input_command" == "serve" ]]; then
        search_string="Server running..."
        jekyll_command="jekyll serve"
    elif [[ "$input_command" == "build" ]]; then
        jekyll_command="jekyll build"
    else
        echo "Invalid command specified: $input_command" >&2
        echo "$help_message"
        exit 1
    fi

    docker_run_command="\
        docker run
            --tty
            --volume \"${local_directory}:/srv/jekyll\"
            \"${docker_image_name}:${docker_tag}\"
            $jekyll_command"
}

docker_run() {
    # shellcheck disable=SC2086
    eval $docker_run_command
}

docker_run_and_test() {
    # shellcheck disable=SC2027,SC2086
    { \
        eval ""$docker_run_command" &"; \
        echo $! > .pid; \
    } | tee /dev/stderr | { \
        grep -m1 "${search_string}" \
        && kill -9 "$(cat .pid)" \
        && rm .pid; \
    }
}

main() {
	initialize "$@"

    echo "Running swedbankpay/jekyll-plantuml:${docker_tag} $input_command..."

    if [[ -n "$search_string" ]]; then
        docker_run_and_test
    else
        docker_run
    fi
}

main "$@"
