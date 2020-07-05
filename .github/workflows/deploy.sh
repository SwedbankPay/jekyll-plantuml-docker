#!/usr/bin/env bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --repository <name> --ref <ref> --token <token> [--verbose]
  $me --help
Arguments:
  -h, --help                Displays this help screen.
  -r, --repository <name>   The name of the GitHub repository to deploy to.
  -R, --ref <ref>           The Git reference of the current commit.
  -t, --token <token>       A GitHub token with access to the repository.
  -i, --image <image>       The fully qualified name of the Docker image to run.
  -v, --verbose             Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ ( $1 = "-r" || $1 = "--repository" ) && -n $2 ]]; then
            repository_name=$2
            shift 2
        elif [[ ( $1 = "-R" || $1 = "--ref" ) && -n $2 ]]; then
            ref=$2
            shift 2
        elif [[ ( $1 = "-t" || $1 = "--token" ) && -n $2 ]]; then
            github_access_token=$2
            shift 2
        elif [[ ( $1 = "-i" || $1 = "--image" ) && -n $2 ]]; then
            docker_image_fqn=$2
            shift 2
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        else
            break
        fi
    done

    if [[ -z "$repository_name" ]]; then
        echo "Missing required argument: --repository <repository-name>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$ref" ]]; then
        echo "Missing required argument: --ref <ref>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$github_access_token" ]]; then
        echo "Missing required argument: --token <token>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$docker_image_fqn" ]]; then
        echo "Missing required argument: --image <image>."
        echo "$help_message"
        return 1
    fi

    # array=("one 1" "two 2" "three 3")

    # copyFiles "${array[@]}"
}

# enforce_required_arguments() {
#     arr=("$@")
#     for i in "${arr[@]}";
#     do
#         echo "$i"
#     done

#     for i in "$[@]"
#     do
#     :
#     # do whatever on $i
#     done
# }

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

    if [[ "$ref" != refs/tags/* ]]; then
      dry_run="--dry-run"
    fi

    docker_run_command="\
          docker run
            --volume \"$(pwd)/tests/full:/srv/jekyll\"
            --env JEKYLL_GITHUB_TOKEN=$github_access_token
            --env PAGES_REPO_NWO=$repository_name
            \"$docker_image_fqn\" \
            deploy $dry_run
            --env=production"

    [ $verbose ] && echo "$docker_run_command"

    # shellcheck disable=SC2086
    eval $docker_run_command
}

main "$@"
