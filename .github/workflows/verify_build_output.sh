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
    --env PAGES_REPO_NWO="${PAGES_REPO_NWO}" \
    --env JEKYLL_GITHUB_TOKEN="${JEKYLL_GITHUB_TOKEN}" \
    --volume "$(pwd):/srv/jekyll" \
    "$docker_image_fqn" \
    jekyll build

result=$(\
    bundle exec htmlproofer \
        _site \
        --check-html \
        --assume-extension \
        --enforce-https \
        --only-4xx \
        --check-opengraph \
)

if [[ $result == *"0 files"* ]]; then
    echo "No files checked! Is _site empty?"
    exit 1
fi
