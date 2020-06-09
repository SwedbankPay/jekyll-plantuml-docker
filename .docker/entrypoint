#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

if [ ! -f "Gemfile" ]; then
  DEFAULT_GEMFILE="${JEKYLL_VAR_DIR}/Gemfile"
  echo "No Gemfile found. Using default: ${DEFAULT_GEMFILE}" 1>&2
  export BUNDLE_GEMFILE="$DEFAULT_GEMFILE"
fi

if [ ! -f "_config.yml" ]; then
  export default_config_file="${JEKYLL_VAR_DIR}/_config.default.yml"
  echo "No _config.yml found. Using default: ${default_config_file}" 1>&2
fi

bundle check || bundle install

if [[ "$1" == "deploy" ]]; then
  echo "Deploying..."
  deploy_config_file="${JEKYLL_VAR_DIR}/_config.deploy.yml"

  if [ -n "$default_config_file" ]; then
    JEKYLL_ENV=production bundle exec jekyll build --config "$default_config_file,$deploy_config_file" --verbose
  else
    config_files=$(find . -name "_config.y*ml")
    JEKYLL_ENV=production bundle exec jekyll build --verbose --config "$config_files,$deploy_config_file"
  fi
  exec /usr/jekyll/bin/deploy.sh --verbose
elif [[ "$1" == "jekyll" ]]; then
  echo "Running Jekyll command '${*:2}' (JEKYLL_ENV: ${JEKYLL_ENV})..."

  # If the default_config_file is assigned and the jekyll command supports '--config',
  # apply the default config by performing some positional argument magic.
  if [ -n "$default_config_file" ] && bundle exec jekyll "$2" --help | grep '\-\-config' > /dev/null; then
    exec bundle exec jekyll "$2" --config "$default_config_file" "${@:3}"
  else
    exec bundle exec jekyll "${@:2}"
  fi
elif [[ -z "$*" ]]; then
  echo "Running default command 'jekyll serve' (JEKYLL_ENV: ${JEKYLL_ENV})..."

  if [ -n "$default_config_file" ]; then
    exec bundle exec jekyll serve --config "$default_config_file" --livereload --incremental --force_polling --watch --host 0.0.0.0
  else
    exec bundle exec jekyll serve --livereload --incremental --force_polling --watch --host 0.0.0.0
  fi
else
  echo "Running '$*' (JEKYLL_ENV: ${JEKYLL_ENV})..."
  exec "$@"
fi
