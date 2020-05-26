#!/bin/bash

initialize() {
	docker_tag=${TAG:-latest}
	local_directory=${JEKYLL_DIR:-"$PWD"}
	search_string=${OUTPUT:-"Server running"}
}

docker_run() {
    echo "Running swedbankpay/jekyll-plantuml:${docker_tag}..."

    { \
        docker run \
            --tty \
            --volume "${local_directory}:/srv/jekyll" \
            "swedbankpay/jekyll-plantuml:${docker_tag}" \
            & echo $! > pid; \
    } | tee /dev/stderr | { \
        grep -m1 "${search_string}" \
        && kill -9 "$(cat pid)" \
        && rm pid; \
    }
}

main() {
	initialize
	docker_run
}

main
