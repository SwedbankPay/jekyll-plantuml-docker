#!/usr/bin/env bash
set -o errexit # Abort if any command fails

parse_args() {
    if [[ "${DEBUG:-false}" = "true" ]]; then
        verbose=true
    else
        verbose=false
    fi

    if [[ "$*" =~ \-\-env[\=\ ]+([^\ ]+) ]]; then
        env="${BASH_REMATCH[1]}"
        [ $verbose ] && echo "Detected --env='$env'."
    fi
}

# echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

main() {
    parse_args "$@"

    enable_expanded_output

    ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/gemfile_generator_exec.rb"

    default_gemfile="${JEKYLL_DATA_DIR}/Gemfile.generated"

    bundle check --gemfile="$default_gemfile" \
      || bundle install --gemfile="$default_gemfile"

    if [[ -n $env ]]; then
        [ $verbose ] && echo "Exporting JEKYLL_ENV='$env'."
        export JEKYLL_ENV="$env"
    fi

    # bundle config set gemfile "$default_gemfile"

    BUNDLE_GEMFILE="$default_gemfile" exec bundle exec ruby "${JEKYLL_VAR_DIR}/entrypoint/lib/entrypoint.rb" "$@"
}

main "$@"

