#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

cd test

bundler_path="$(which bundle)"
if [ -x "$bundler_path" ] ; then
    echo "$bundler_path exists."
else
    echo "Bundler not present, installing..."
    gem install bundler
fi

echo "Configuring and installing gems..."

bundle config path "$(pwd)/vendor/bundle"
bundle check || bundle install

docker_image_name="${IMAGE_NAME:-swedbankpay/jekyll-plantuml}"
docker_image_tag="${IMAGE_TAG:-latest}"
docker_image_fqn="${docker_image_name}:${docker_image_tag}"

echo "Running $docker_image_fqn..."

docker run \
    --env JEKYLL_ENV=production \
    --tty \
    --volume "$(pwd):/srv/jekyll" \
    "$docker_image_fqn" \
    jekyll build

bundle exec rake
