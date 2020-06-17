#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

if [ ! -f "Gemfile" ]; then
  DEFAULT_GEMFILE="${JEKYLL_VAR_DIR}/entrypoint/Gemfile"
  echo "No Gemfile found. Using default: ${DEFAULT_GEMFILE}" 1>&2
  export BUNDLE_GEMFILE="$DEFAULT_GEMFILE"
fi

# bundle check --path $BUNDLE_PATH || bundle install

bundle config build --use-system-libraries && \
    bundle config build.jekyll --use-system-libraries && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config set system 'true' && \
    bundle config set clean 'true' && \
    bundle config set deployment 'true' && \
    bundle check || \
    bundle install

exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
