#!/usr/bin/env bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Execute a Jekyll command in the Docker container and optionally test the output.

Usage:
  $me (build | serve) --image <image> --dir <dir> --repository <name> --token <token> [--verbose] [--no-pull]
  $me --help

Arguments:
  build                     Builds and returns the exit code from the build.
  serve                     Serves and searches for 'Server running...' in the
                            output generated by Jekyll. Exits successfully if
                            the output can be found, otherwise fails.
  -h, --help                Displays this help screen.
  -i, --image <image>       The fully qualified name of the Docker image to test.
  -d, --dir                 The content directory to use for Jekyll.
  -r, --repository <name>   The name of the GitHub repository to deploy to.
  -t, --token <token>       A GitHub token with access to the repository.
  -n, --no-pull             Does not perform 'docker pull' of the image.
  -v, --verbose             Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "build" || $1 = "serve" ]]; then
            jekyll_command=$1
            shift
        elif [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ ( $1 = "-i" || $1 = "--image" ) && -n $2 ]]; then
            docker_image_fqn=$2
            shift 2
        elif [[ ( $1 = "-r" || $1 = "--repository" ) && -n $2 ]]; then
            repository_name=$2
            shift 2
        elif [[ ( $1 = "-d" || $1 = "--dir" ) && -n $2 ]]; then
            local_directory=$2
            shift 2
        elif [[ ( $1 = "-t" || $1 = "--token" ) && -n $2 ]]; then
            github_access_token=$2
            shift 2
        elif [[ $1 = "-n" || $1 = "--no-pull" ]]; then
            no_pull=true
            shift
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        else
            break
        fi
    done

    if [[ -z "$jekyll_command" ]]; then
        echo "Missing required argument: (build | serve)."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$docker_image_fqn" ]]; then
        echo "Missing required argument: --image <image>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$repository_name" ]]; then
        echo "Missing required argument: --repository <name>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$github_access_token" ]]; then
        echo "Missing required argument: --token <token>."
        echo "$help_message"
        return 1
    fi

    if [[ "$jekyll_command" == "serve" ]]; then
        search_string="Server running..."
    fi

    if [[ $verbose ]]; then
        debug_env="--env DEBUG=true"
    fi

    docker_run_command="\
        docker run
            --tty $debug_env
            --env PAGES_REPO_NWO=$repository_name
            --env JEKYLL_GITHUB_TOKEN=$github_access_token
            --env DOCKER_IMAGE_TAG=latest
            --volume \"${local_directory}:/srv/jekyll\"
            \"${docker_image_fqn}\"
            $jekyll_command"

    [ $verbose ] && echo "$docker_run_command"
}

# echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

docker_run() {
    # shellcheck disable=SC2086
    eval $docker_run_command
}

docker_run_and_test() {
    # shellcheck disable=SC2027,SC2086
    { \
        eval ""$docker_run_command" &"; \
        echo $! > .pid; \
    } | tee /dev/stderr | { \
        grep -m1 "${search_string}" \
        && kill -9 "$(cat .pid)" \
        && rm .pid; \
    }
}

main() {
    parse_args "$@"

    enable_expanded_output

    if [[ "$docker_image_fqn" == *docker.pkg.github.com* ]]; then
      [ $verbose ] && echo "Logging into docker.pkg.github.com..."
      docker login https://docker.pkg.github.com -u SwedbankPay -p "$github_access_token"
    fi

    if [[ $no_pull ]]; then
      [ $verbose ] && echo "Not pulling $docker_image_fqn."
    else
      [ $verbose ] && echo "Pulling $docker_image_fqn..."
      docker pull "$docker_image_fqn"
    fi

    [ $verbose ] && echo "Running ${docker_image_fqn} $jekyll_command..."

    if [[ -n "$search_string" ]]; then
        docker_run_and_test
    else
        docker_run
    fi
}

main "$@"
