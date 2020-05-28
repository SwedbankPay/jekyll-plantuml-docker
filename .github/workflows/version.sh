#!/bin/bash

if [[ -z "$SHA" ]]; then
    echo "Environment variable SHA missing."
    exit 1
fi

if [[ -z "$REF" ]]; then
    echo "Environment variable REF missing."
    exit 1
fi

if [[ "$REF" == refs/tags/* ]]; then
    version="${REF#refs/tags/}"
else
    version="$(echo "${SHA}" | cut -c1-8)"
fi

echo "Version: ${version}"
echo "::set-output name=version::${version}"
