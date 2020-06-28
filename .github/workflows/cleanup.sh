#!/usr/bin/env bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  $me --branch <branch-name> --commit <commit-sha> [--remote] [--verbose]
  $me --help
Arguments:
  -h, --help                    Displays this help screen
  -b, --branch <branch-name>    The name of the branch to verify.
  -c, --commit <commit-sha>     The SHA of the commit to clean up.
  -r, --remote                  Also cleans up the remote 'origin'.
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
    while : ; do
        if [[ $1 = "-h" || $1 = "--help" ]]; then
            echo "$help_message"
            return 0
        elif [[ ( $1 = "-b" || $1 = "--branch" ) && -n $2 ]]; then
            branch_name=$2
            shift 2
        elif [[ ( $1 = "-c" || $1 = "--commit" ) && -n $2 ]]; then
            commit_sha=$2
            shift 2
        elif [[ ( $1 = "-r" || $1 = "--remote" ) ]]; then
            cleanup_remote=true
            shift
        elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
            verbose=true
            shift
        else
            break
        fi
    done

    if [[ -z "$branch_name" ]]; then
        echo "Missing required argument: --branch <branch-name>."
        echo "$help_message"
        return 1
    fi

    if [[ -z "$commit_sha" ]]; then
        echo "Missing required argument: --commit <commit-sha>."
        echo "$help_message"
        return 1
    fi
}

#echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ $verbose ]; then
        set -o xtrace
        set +o verbose
    fi
}

main() {
    parse_args "$@"

    enable_expanded_output

    git fetch --depth=1 origin
    git config advice.detachedHead false
    git checkout --force "$commit_sha"

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        [ $verbose ] && echo "Local branch '$branch_name' found. Deleting"
        git branch --delete --force "$branch_name"
    else
        [ $verbose ] && echo "Local branch '$branch_name' not found."
    fi

    if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        [ $verbose ] && echo "Origin branch '$branch_name' found."

        if [ $cleanup_remote ]; then
            [ $verbose ] && echo "Deleting branch '$branch_name' from the remote 'origin'."
            git push --delete origin "$branch_name"
        else
            [ $verbose ] && echo "Not instructed to clean up remote, so '$branch_name' will be left untouched on 'origin'."
        fi
    else
        [ $verbose ] && echo "Origin branch '$branch_name' not found."
    fi

}

main "$@"
