#!/bin/bash

initialize() {
	docker_tag=${TAG:-latest}
	local_directory=${JEKYLL_DIR:-"$PWD"}
	search_string=${OUTPUT:-"Server running"}
    jekyll_command="$*"
}

docker_run() {
    # shellcheck disable=SC2086
    docker run \
        --tty \
        --volume "${local_directory}:/srv/jekyll" \
        "swedbankpay/jekyll-plantuml:${docker_tag}" \
        $jekyll_command \
        & echo $! > pid;
}

docker_test() {
    grep -m1 "${search_string}" \
        && kill -9 "$(cat pid)" \
        && rm pid;
}

docker_run_and_test() {
    echo "Running swedbankpay/jekyll-plantuml:${docker_tag}..."

    docker_run | tee /dev/stderr | docker_test
}

main() {
	initialize "$@" && docker_run_and_test
}

main "$@"
