#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/gemfile_generator_exec.rb"

default_gemfile="${JEKYLL_VAR_DIR}/entrypoint/Gemfile.generated"

bundle check --gemfile="$default_gemfile" \
  || bundle install --gemfile="$default_gemfile"

bundle config set gemfile "$default_gemfile"

exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
