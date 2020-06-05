#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

#Spin up docker
# shellcheck disable=SC2046
docker run -d -p 4000:4000 --tty --volume $(pwd)/:/srv/jekyll swedbankpay/jekyll-plantuml:latest

gem install bundler
bundle install --gemfile ./.docker/rake/Gemfile
#Rake requires liburl
sudo apt-get install libcurl4

rake -f ./.docker/./rake/Rakefile

docker stop $(docker ps -a -q --filter ancestor=swedbankpay/jekyll-plantuml:latest --format="{{.ID}}")
