#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/generate-gemfile.rb"

default_gemfile="${JEKYLL_VAR_DIR}/entrypoint/Gemfile_generated"

bundle check --gemfile="$default_gemfile" \
  || bundle install --gemfile="$default_gemfile"

bundle config set gemfile $default_gemfile

exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
