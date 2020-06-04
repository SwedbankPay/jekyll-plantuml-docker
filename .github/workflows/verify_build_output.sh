#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

#Spin up docker
# shellcheck disable=SC2046
docker run -d -p 4000:4000 --tty --volume $(pwd)/.docker/jekyll-plantuml/:/srv/jekyll swedbankpay/jekyll-plantuml:latest

bundle install --gemfile ./.docker/rake/Gemfile

rake -f ./rake/Rakefile

docker stop swedbankpay/jekyll-plantuml:latest
