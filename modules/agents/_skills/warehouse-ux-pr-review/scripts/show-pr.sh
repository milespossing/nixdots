#!/usr/bin/env bash
# Show one PR's metadata, files changed, and full diff.
#
# Usage: show-pr.sh <pull-request-id>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
ensure_az_login || exit 1

PR="${1:?usage: show-pr.sh <pr-id>}"

echo "## Metadata"
az repos pr show --org "$ORG" --id "$PR" --query '{
  id: pullRequestId,
  title: title,
  status: status,
  author: createdBy.displayName,
  source: sourceRefName,
  target: targetRefName,
  isDraft: isDraft,
  url: ("https://dev.azure.com/powerbi/Trident/_git/TridentWarehouse-UX/pullrequest/" + (pullRequestId | tostring))
}' -o json

echo
echo "## Description"
az repos pr show --org "$ORG" --id "$PR" --query 'description' -o tsv

echo
echo "## Files changed"
azdo_rest "pullRequests/${PR}/iterations/1/changes?api-version=7.1&\$top=1000" \
  --query 'changeEntries[].{path: item.path, type: changeType}' -o table

# Get source/target commits for the diff.
SOURCE=$(az repos pr show --org "$ORG" --id "$PR" --query 'lastMergeSourceCommit.commitId' -o tsv)
TARGET=$(az repos pr show --org "$ORG" --id "$PR" --query 'lastMergeTargetCommit.commitId' -o tsv)

echo
echo "## Diff ($TARGET..$SOURCE)"
# Use the diffs API to get a textual diff per file.
azdo_rest "diffs/commits?baseVersion=${TARGET}&targetVersion=${SOURCE}&baseVersionType=commit&targetVersionType=commit&api-version=7.1" \
  --query 'changes[].item.path' -o tsv | while read -r path; do
  [ -z "$path" ] && continue
  echo
  echo "### $path"
  echo '```diff'
  # Pull both versions and produce a unified diff locally; the
  # devops "diff" endpoint doesn't return patch text directly.
  base=$(azdo_rest "items?path=${path}&versionDescriptor.version=${TARGET}&versionDescriptor.versionType=commit&api-version=7.1&includeContent=true" \
    --query content -o tsv 2>/dev/null || true)
  tgt=$(azdo_rest "items?path=${path}&versionDescriptor.version=${SOURCE}&versionDescriptor.versionType=commit&api-version=7.1&includeContent=true" \
    --query content -o tsv 2>/dev/null || true)
  diff -u <(printf '%s' "$base") <(printf '%s' "$tgt") || true
  echo '```'
done
