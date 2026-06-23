#!/usr/bin/env bash
# List PRs in the TridentWarehouse-UX repo as a Markdown table.
#
# Usage:
#   list-prs.sh [--status active|completed|abandoned|all]
#               [--mine] [--reviewing]
#               [--top N] [--days N] [--no-enrich]
#
# Defaults: active PRs plus PRs completed in the last 7 days, top 50,
# sorted most-recently-updated first. Enrichment (file/comment counts)
# is on by default; pass --no-enrich for a much faster listing.
#
# Progress is written to stderr so the script never looks hung.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
ensure_az_login || exit 1

STATUS="default"
MINE=0
REVIEWING=0
TOP=50
DAYS=7
ENRICH=1

while [ $# -gt 0 ]; do
  case "$1" in
    --status) STATUS="$2"; shift 2;;
    --mine) MINE=1; shift;;
    --reviewing) REVIEWING=1; shift;;
    --top) TOP="$2"; shift 2;;
    --days) DAYS="$2"; shift 2;;
    --no-enrich) ENRICH=0; shift;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

log() { printf '[list-prs] %s\n' "$*" >&2; }

extra=()
if [ "$MINE" = "1" ]; then
  extra+=(--creator "$(my_identity_id)")
fi
if [ "$REVIEWING" = "1" ]; then
  extra+=(--reviewer "$(my_identity_id)")
fi

fetch() {
  local status="$1"
  az repos pr list \
    --org "$ORG" --project "$PROJECT" --repository "$REPO" \
    --status "$status" --top "$TOP" "${extra[@]}" 2>/dev/null
}

if [ "$STATUS" = "default" ]; then
  log "fetching active PRs..."
  ACTIVE=$(fetch active)
  log "fetching completed PRs (last $DAYS days)..."
  COMPLETED=$(fetch completed)
  CUTOFF=$(date -u -d "$DAYS days ago" +%Y-%m-%dT%H:%M:%SZ)
  ALL=$(jq -s --arg cutoff "$CUTOFF" '
    .[0] + ([.[1][] | select(.closedDate > $cutoff)])
  ' <(echo "$ACTIVE") <(echo "$COMPLETED"))
else
  log "fetching $STATUS PRs..."
  ALL=$(fetch "$STATUS")
fi
N=$(echo "$ALL" | jq 'length')
log "got $N PRs"

# Enrich each PR with file count and non-system comment count.
# Each enrich call spawns two `az rest` invocations (each ~1-2s of
# Python startup), so we parallelize aggressively and print a dot per
# PR to stderr to make progress visible.
enrich() {
  local pr_id="$1"
  local files cmts
  files=$(az rest --resource "$AZDO_RESOURCE" \
    --uri "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/${REPO_ID}/pullRequests/${pr_id}/iterations/1/changes?api-version=7.1&\$top=1000" \
    --query 'length(changeEntries)' -o tsv 2>/dev/null || echo "?")
  cmts=$(az rest --resource "$AZDO_RESOURCE" \
    --uri "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/${REPO_ID}/pullRequests/${pr_id}/threads?api-version=7.1" \
    --query "length(value[?!(comments[0].commentType == 'system')])" -o tsv 2>/dev/null || echo "?")
  printf '.' >&2
  echo "$pr_id|$files|$cmts"
}
export -f enrich
export REPO_ID AZDO_RESOURCE

PR_IDS=$(echo "$ALL" | jq -r '.[].pullRequestId')
if [ "$ENRICH" = "1" ]; then
  log "enriching $N PRs (file + comment counts, parallel=16)..."
  ENRICHED=$(echo "$PR_IDS" | xargs -P 16 -I{} bash -c 'enrich "$@"' _ {})
  printf '\n' >&2
else
  ENRICHED=$(echo "$PR_IDS" | awk '{print $1"|?|?"}')
fi

# Merge enrichment back into JSON.
MERGED=$(jq -n --argjson prs "$ALL" --arg enriched "$ENRICHED" '
  ($enriched | split("\n") | map(select(length > 0) | split("|") | {
    id: (.[0] | tonumber), files: .[1], cmts: .[2]
  })) as $e
  | $prs | map(. as $p | . + ($e[] | select(.id == $p.pullRequestId)))
')

# Sort by last activity (use creationDate as a fallback proxy).
echo "$MERGED" | jq -r '
  sort_by(.creationDate) | reverse
  | (["ID","Status","Author","Files","Cmts","Updated","Title"], ["---","---","---","---","---","---","---"]),
    (.[] | [
      (.pullRequestId | tostring),
      (.status),
      (.createdBy.displayName),
      (.files // "?"),
      (.cmts // "?"),
      (.creationDate[0:10]),
      ((.title // "") | gsub("\\|"; "\\|") | .[0:80])
    ])
  | "| " + join(" | ") + " |"
'
