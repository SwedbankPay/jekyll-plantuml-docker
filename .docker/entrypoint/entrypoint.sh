#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

if [ ! -f "Gemfile" ]; then
  DEFAULT_GEMFILE="${JEKYLL_VAR_DIR}/Gemfile"
  echo "No Gemfile found. Using default: ${DEFAULT_GEMFILE}" 1>&2
  export BUNDLE_GEMFILE="$DEFAULT_GEMFILE"
fi

bundle check || bundle install

exec bundle exec ruby "${JEKYLL_BIN}/entrypoint.rb" "$@"
