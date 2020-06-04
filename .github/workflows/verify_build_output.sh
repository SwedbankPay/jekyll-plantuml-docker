#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

#Spin up docker
# shellcheck disable=SC2046
docker run -d -p 4000:4000 --tty --volume $(pwd)/.docker/jekyll-plantuml/:/srv/jekyll swedbankpay/jekyll-plantuml:latest

gem install bundler
bundle install --gemfile ./.docker/rake/Gemfile --deployment
#Rake requires liburl
sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev

rake -f ./.docker/./rake/Rakefile

docker rm "$(docker stop "$(docker ps -a -q --filter ancestor=swedbankpay/jekyll-plantuml:latest --format="{{.ID}})")")"
