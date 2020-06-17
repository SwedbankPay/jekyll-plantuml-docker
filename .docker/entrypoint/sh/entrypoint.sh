#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

default_gemfile="${JEKYLL_VAR_DIR}/entrypoint/Gemfile"

bundle check --gemfile="$default_gemfile" \
  || bundle install --gemfile="$default_gemfile"

exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
