#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

if [[ -z "$IMAGE_TAG" ]]; then
    echo "Missing IMAGE_TAG environment variable. Aborting."
    exit 1
fi

docker_image_name="${IMAGE_NAME:-swedbankpay/jekyll-plantuml}"
docker_image_fqn="$docker_image_name:$IMAGE_TAG"

cd test

echo "Running $docker_image_fqn"

# Spin up docker
docker run \
    --detach \
    --publish 4000:4000 \
    --tty \
    --volume "$(pwd):/srv/jekyll" \
    "$docker_image_fqn" \
    jekyll build

echo "Installing gems"

gem install bundler

bundle config path "$(pwd)/vendor/bundle"
bundle install

bundle exec rake

container_id=$(docker ps -a -q --filter ancestor="$docker_image_fqn" --format="{{.ID}}")

echo "Stopping $container_id"
docker stop "$container_id"
