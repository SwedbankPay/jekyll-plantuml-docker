#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

me=$(basename "$0")

help_message="\
Usage: $me <target-folder>

Deletes all files and folders mentioned in .dockerignore from the
<target-folder>."

workdir="${JEKYLL_VAR_DIR:-$(pwd)}"
target_folder="$1"
dockerignore_file="${workdir}/.dockerignore"

if [[ -z "$target_folder" ]]; then
  echo "$help_message"
  exit 1
fi

if [[ ! -f "$dockerignore_file" ]]; then
  echo "Error! $dockerignore_file cannot be found."
  echo "$help_message"
  exit 1
fi

find_cmd=""

while read -r ignore; do
  if [[ "$ignore" != "#"* ]] && [[ -n "$ignore" ]]; then
    if [[ "$find_cmd" == "" ]]; then
      find_cmd=" -name '$ignore'"
    else
      find_cmd="$find_cmd -o -name '$ignore'"
    fi
  fi
done <"$dockerignore_file"

find_cmd="find $target_folder \( $find_cmd \) -prune -exec rm -rfv {} \;"

echo "Removing files matching $dockerignore_file:"

[ "${DEBUG:-false}" = "true" ] && echo "$find_cmd"

eval "$find_cmd"
