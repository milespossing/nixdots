---
name: warehouse-ux-pr-review
description: Use when the user asks to list, triage, or review pull requests for the TridentWarehouse-UX repo (dev.azure.com/powerbi/Trident/_git/TridentWarehouse-UX) — including "show me open PRs", "review PR <id>", "what's waiting on me", or any code-review work against that Azure DevOps repo.
metadata:
  author: miles
  org: https://dev.azure.com/powerbi
  project: Trident
  repository: TridentWarehouse-UX
---

# Warehouse-UX PR review

Tools and conventions for working with pull requests in
`dev.azure.com/powerbi/Trident/_git/TridentWarehouse-UX`.

The repo:

- **Org:** `https://dev.azure.com/powerbi`
- **Project:** `Trident`
- **Repository:** `TridentWarehouse-UX`
- **Web URL:** https://dev.azure.com/powerbi/Trident/_git/TridentWarehouse-UX/pullrequests

All Azure DevOps work goes through the **`azure-devops` MCP server**
(Microsoft's official `@azure-devops/mcp`, configured for org `powerbi`,
authenticating via the local `az login` session). Tools are prefixed
`mcp_ado_` — use them in preference to shell scripts.

**Repo id (use this in MCP calls, much faster than name lookups):**
`bde35e51-d934-4f33-83ef-618d3498079d`

**Auth.** The MCP server uses `--authentication azcli`, so it inherits
the local `az login` session. If a tool call comes back with a 401 /
"unable to acquire token" / "interactive authentication required"
error, **surface it to the user verbatim** along with:

```
az login --tenant 72f988bf-86f1-41af-91ab-2d7cd011db47
```

Do not retry, do not fall back to scraping — stop and ask the user to
run `az login` in their own terminal, then retry.

## When to use this skill

Load this skill when the user asks for any of:

- "list / show / what are the open PRs" for warehouse-ux / TridentWarehouse-UX
- "review PR <id>" or "review this PR" against that repo
- "what PRs are waiting on me", "what's in my queue"
- "what did I miss", "summarize recent PRs"
- Any code review work where the target is a PR in this repo

## Procedure

### 1. Listing PRs

Use `mcp_ado_repo_list_pull_requests_by_repo_or_project` with
`repositoryId = bde35e51-d934-4f33-83ef-618d3498079d`. Useful filters:

- `status` — `active` (default for triage), `completed`, `abandoned`, `all`
- `creatorId` — for "PRs I authored"
- `reviewerId` — for "PRs waiting on me"
- `top` / `skip` — paginate

For "what's open right now" the typical call is just
`{ repositoryId, status: "active" }`. For "what did I miss", call
twice — once `active` and once `completed`, then filter the completed
set to the last 7 days client-side.

If the user asks for file or comment counts per PR, follow up with
`mcp_ado_repo_get_pull_request_by_id` (file count) and
`mcp_ado_repo_list_pull_request_threads` (filter out
`commentType == "system"` for the real comment count). Don't fetch
these for every PR by default — only when asked, since each PR costs
a round trip.

Present the result as a Markdown table with columns
`ID | Status | Author | Updated | Title`. Don't dump JSON at the user.

### 2. Reviewing a single PR

When the user says "review PR 1234" or "review this PR" with a URL:

1. Extract the PR id.
2. Fetch metadata and diff via MCP:
   - `mcp_ado_repo_get_pull_request_by_id` —
     `{ repositoryId, pullRequestId }` for title, description, labels,
     work items, changed files.
   - `mcp_ado_repo_get_pull_request_changes` —
     `{ repositoryId, pullRequestId, includeDiffs: true, includeLineContent: true }`
     for the unified diff with `originalLines` / `modifiedLines`.
   - `mcp_ado_repo_list_pull_request_threads` (optional) to see what
     other reviewers have already said before duplicating their
     comments.
3. **Read [`references/review-philosophy.md`](references/review-philosophy.md) first.**
   Start with section 0 (Gestalt) — that's the *why* under every
   specific rule. Then section 3 (rules), section 4 (move shapes),
   section 5 (heuristics for producing candidates).
4. Walk the diff applying section 5's heuristics. For each thing that
   triggers a heuristic, produce a **candidate comment** — not a
   verdict.
5. Output: a list of candidates grouped by file. **Never post anything
   to Azure DevOps.** **Never decide what's worth blocking on, what's
   worth approving, or whether to praise.** Surface the candidate;
   the user picks.

For each candidate include:

- **Severity tag** (`question` / `nit` / `suggest` / `concern` /
  `praise`) — these are hints to the user, not decisions.
- **Location** as `file:line` (per this repo's `AGENTS.md`
  convention).
- **Evidence**: a short list of other files/lines the user should
  open to verify the concern — peer features, the type definition,
  the slice the data comes from, a counter-example pattern elsewhere
  in the codebase. The user reads these before deciding whether to
  leave the comment.
- **Why** — which rule from section 3 applies, in one line.
- **Draft comment** in the tone of section 4, ready to copy or
  refine.

Do not filter candidates based on what *seems* worth enforcing — the
user makes that call. If a heuristic fires, surface it.

### 3. Posting a comment (only on explicit ask)

Only when the user explicitly says "post this", use:

- `mcp_ado_repo_create_pull_request_thread` — to start a new top-level
  or inline (file/line) review thread.
- `mcp_ado_repo_reply_to_comment` — to reply within an existing
  thread.
- `mcp_ado_repo_update_pull_request_thread` — to resolve / reactivate
  a thread.
- `mcp_ado_repo_vote_pull_request` — only if the user explicitly asks
  to approve / reject.

For inline comments, pass the file path and line range in the thread
context per the tool's schema. Read back the response so the user sees
the posted thread id.

## References

- [`references/review-philosophy.md`](references/review-philosophy.md) —
  distilled lens, tone, and architectural rules from ~1,150 of my
  comments across 482 PRs in this repo. **Always read before reviewing.**
- [`assets/redux-style-guide.md`](assets/redux-style-guide.md) — offline
  mirror of the official Redux style guide
  (<https://redux.js.org/style-guide/style-guide>). The architectural
  rules in section 3a of the philosophy build on this; load it when a
  PR touches `slice`, `epic`, `selector`, `createEntityAdapter`,
  `createListenerMiddleware`, or otherwise involves Redux state shape
  decisions.

## Fallback scripts

If the MCP server is unavailable (e.g. on a host that doesn't have the
MCP wired up, or while debugging an MCP issue), the `scripts/`
directory contains shell-script equivalents that use `az rest`
directly:

- [`scripts/list-prs.sh`](scripts/list-prs.sh) — list active + recent PRs.
- [`scripts/show-pr.sh`](scripts/show-pr.sh) — fetch one PR's metadata,
  files, and diff.
- [`scripts/common.sh`](scripts/common.sh) — shared org/project/repo
  constants and auth helpers (sourced by the other scripts).

The scripts are slower (each `az rest` call pays ~1-2s of Python
startup) but otherwise equivalent. **Prefer the MCP tools when they
are available.**