#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

if [[ -z "$IMAGE_TAG" ]]; then
    echo "Missing IMAGE_TAG environment variable. Aborting."
    exit 1
fi

docker_image_name="${IMAGE_NAME:-swedbankpay/jekyll-plantuml}"
docker_image_fqn="$docker_image_name:$IMAGE_TAG"

echo "Running $docker_image_fqn"

cd test

# Spin up docker
docker run \
    --detach \
    --publish 4000:4000 \
    --tty \
    --volume "$(pwd)/test:/srv/jekyll" \
    "$docker_image_fqn"

gem install bundler

bundle config path vendor/bundle
bundle install

rake

container_id=$(docker ps -a -q --filter ancestor="$docker_image_fqn" --format="{{.ID}}")

echo "Stopping $container_id"
docker stop "$container_id"
