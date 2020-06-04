#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

#Spin up docker
docker run --tty --volume $(pwd)/.docker/jekyll-plantuml/:/srv/jekyll swedbankpay/jekyll-plantuml:latest -d

bundle install rake

rake -f ./rake/Rakefile

docker stop swedbankpay/jekyll-plantuml:latest
