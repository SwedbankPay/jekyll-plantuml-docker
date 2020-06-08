#!/bin/bash
set -o errexit #abort if any command fails

[ "${DEBUG:-false}" = "true" ] && set -x

cd test

echo "Installing gems"

gem install bundler

bundle config path "$(pwd)/vendor/bundle"
bundle install

bundle exec rake
