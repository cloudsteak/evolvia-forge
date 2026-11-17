#!/usr/bin/env bash
set -euo pipefail

token="$(az account get-access-token --scope "https://ai.azure.com/.default" --query accessToken --output tsv)"

# The Foundry User assignment has to propagate before the data-plane upload is accepted.
sleep 45

shopt -s nullglob
for file in "$DOC_DIR"/*; do
  [ -f "$file" ] || continue
  curl --fail --silent --show-error --request POST \
    --url "$PROJECT_FILES_ENDPOINT" \
    --header "Authorization: Bearer ${token}" \
    --form purpose="assistants" \
    --form "file=@${file}" \
    --output /dev/null
done
