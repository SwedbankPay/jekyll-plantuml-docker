#!/bin/sh
files_with_control_characters=$(\
    grep --color='always' \
        --perl-regexp \
        --line-number \
        --byte-offset \
        --exclude-dir='.git' \
        --recursive \
        "[\x80-\xFF]" \
        . \
)
if [[ -n $files_with_control_characters ]]; then
  echo "Files with control characters detected!"
  echo ""
  echo "$files_with_control_characters"
  exit 1
else
  echo "No control characters detected. All good."
fi
