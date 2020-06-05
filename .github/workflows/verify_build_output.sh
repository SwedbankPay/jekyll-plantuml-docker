#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

if [[ -z "$IMAGE_TAG" ]]; then
    echo "Missing IMAGE_TAG environment variable. Aborting."
    exit 1
fi

image_fqn="swedbankpay/jekyll-plantuml:$IMAGE_TAG"

echo "Running $image_fqn"

# Spin up docker
docker run \
    --detach \
    --publish 4000:4000 \
    --tty \
    --volume "$(pwd)/.docker/jekyll-plantuml:/srv/jekyll" \
    "$image_fqn"

gem install bundler
bundle install --gemfile ./.docker/rake/Gemfile
# Rake requires liburl
sudo apt-get install libcurl4

rake -f ./.docker/rake/Rakefile

container_id=$(docker ps -a -q --filter ancestor="$image_fqn" --format="{{.ID}}")

echo "Stopping $container_id"
docker stop "$container_id"
