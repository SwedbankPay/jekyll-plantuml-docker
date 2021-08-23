#!/bin/bash

sudo apt-get update

JSON=$(cat apt.json)

for PACKAGE in $(echo "$JSON" | jq -r 'keys | .[]'); do
    VERSION=$(apt-cache policy "$PACKAGE" | grep -oP '(?<=Candidate:\s)(.+)')
    echo "Updating '$PACKAGE' to version $VERSION."
    JSON=$(echo "$JSON" | jq '.[$package] = $version' --arg package "$PACKAGE" --arg version "$VERSION")
done

echo "Writing apt.json to disk:"
echo "$JSON"
echo "$JSON" | python -m json.tool > apt.json
