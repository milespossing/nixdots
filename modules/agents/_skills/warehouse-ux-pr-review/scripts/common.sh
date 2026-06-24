#!/usr/bin/env bash
# Shared constants and helpers for the warehouse-ux-pr-review skill.
# Source this file: `source "$(dirname "$0")/common.sh"`

export ORG="https://dev.azure.com/powerbi"
export PROJECT="Trident"
export REPO="TridentWarehouse-UX"
# Stable repo id (avoids a name lookup on every call):
export REPO_ID="bde35e51-d934-4f33-83ef-618d3498079d"
# Azure DevOps resource id for AAD tokens:
export AZDO_RESOURCE="499b84ac-1321-427f-aa17-267ca6975798"

# Never let az prompt interactively. Without this, an expired login can
# cause `az` to hang waiting on stdin when the skill is run from an
# agent shell that has no TTY.
export AZURE_CORE_NO_PROMPT=1
export AZURE_CORE_LOGIN_EXPERIENCE_V2=off

# Fail fast (and loudly) if az isn't logged in or the token can't be
# refreshed non-interactively. Run this before any other az call.
ensure_az_login() {
  # Belt and suspenders: even with AZURE_CORE_NO_PROMPT set, some
  # broker / WAM code paths can still block. Wrap every probe in a
  # hard timeout so this function can never hang the caller.
  printf '[ensure_az_login] checking account...\n' >&2
  if ! timeout 10 az account show --only-show-errors >/dev/null 2>&1; then
    cat >&2 <<'EOF'
ERROR: az is not logged in.

Run this in your terminal, then re-run the skill:

  az login --tenant 72f988bf-86f1-41af-91ab-2d7cd011db47

If you are already logged in but the token has expired (the AAD
conditional-access policy expires tokens fairly often), the same
command will refresh it.
EOF
    return 1
  fi

  # Probe the Azure DevOps resource specifically — `az account show`
  # passing is necessary but not sufficient when conditional-access
  # token-protection is in play.
  printf '[ensure_az_login] probing Azure DevOps token...\n' >&2
  if ! timeout 15 az account get-access-token --resource "$AZDO_RESOURCE" \
        --only-show-errors >/dev/null 2>&1; then
    cat >&2 <<'EOF'
ERROR: az is logged in, but cannot mint an Azure DevOps token
(likely a conditional-access token-protection expiration).

Run this in your terminal, then re-run the skill:

  az login --tenant 72f988bf-86f1-41af-91ab-2d7cd011db47 \
           --scope 499b84ac-1321-427f-aa17-267ca6975798/.default
EOF
    return 1
  fi
  printf '[ensure_az_login] ok\n' >&2
}

# Set the default org/project for the `az repos` CLI so callers don't
# have to repeat them.
az devops configure --defaults organization="$ORG" project="$PROJECT" >/dev/null 2>&1 || true

# Echo a bearer token for the Azure DevOps REST API.
azdo_token() {
  az account get-access-token --resource "$AZDO_RESOURCE" --query accessToken -o tsv
}

# azdo_rest <path> [extra args...]
# `path` is everything after the repo base URL. Uses `az rest`
# because curl/wget are blocked in some sandboxed agent shells.
# Note: each `az rest` call pays ~1-2s of Python startup; parallelize.
azdo_rest() {
  local path="$1"; shift
  az rest --resource "$AZDO_RESOURCE" \
    --uri "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/${REPO_ID}/${path}" \
    "$@"
}

# Resolve the signed-in user's Azure DevOps identity id (caches in /tmp).
my_identity_id() {
  local cache="${TMPDIR:-/tmp}/azdo-my-id-$(id -u)"
  if [ ! -s "$cache" ]; then
    local upn
    upn=$(az account show --query user.name -o tsv)
    az rest --resource "$AZDO_RESOURCE" \
      --uri "https://vssps.dev.azure.com/powerbi/_apis/identities?searchFilter=General&filterValue=${upn}&api-version=7.1" \
      --query 'value[0].id' -o tsv > "$cache"
  fi
  cat "$cache"
}
