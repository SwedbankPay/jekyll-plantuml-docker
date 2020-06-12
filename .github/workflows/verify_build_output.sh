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

bundle exec rake
