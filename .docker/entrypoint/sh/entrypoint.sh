#!/bin/bash
set -o errexit # Immediately abort if any command fails

if [ "${DEBUG:-false}" = "true" ]; then
  set -x
  # export JEKYLL_LOG_LEVEL="debug"
fi

ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/gemfile_generator_exec.rb"

default_gemfile="${JEKYLL_DATA_DIR}/Gemfile.generated"

bundle check --gemfile="$default_gemfile" \
  || bundle install --gemfile="$default_gemfile"

bundle config set gemfile "$default_gemfile"

exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
