---
name: pr-review
description: Review Azure DevOps pull requests interactively. List open PRs, explore diffs, build review suggestions, then post them as PR comment threads. Use when the user wants to review PRs, give feedback on pull requests, or check what PRs need review.
---

# Azure DevOps PR Review

Interactive pull request review workflow for Azure DevOps repositories.
Supports listing, exploring, and reviewing PRs with a structured
suggestion-then-send flow.

## Prerequisites

- `az` CLI authenticated (`az login`)
- Azure DevOps extension installed (`az extension add --name azure-devops`)

## Configured Repositories

These are the repositories to review PRs from:

| Alias          | Organization | Project | Repository          |
| -------------- | ------------ | ------- | ------------------- |
| warehouse-ux   | powerbi      | Trident | TridentWarehouse-UX |
| specs-dw       | powerbi      | Trident | specs-dw            |

When listing PRs, query **all** configured repositories unless the user
specifies a particular one.

All `az repos` commands must include:

```
--organization https://dev.azure.com/powerbi --project Trident
```

The REST API base URL for all repos is:

```
https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>
```

Use API version `7.0` for all REST calls.

## Workflow

The review follows a strict phased workflow. Move through each phase in order.
Do NOT skip ahead or post comments without the user explicitly approving.

### Phase 1 — Pick a PR

List open PRs assigned to the user for review across all configured repos:

```bash
# For each configured repository:
az repos pr list \
  --repository TridentWarehouse-UX \
  --project Trident \
  --organization https://dev.azure.com/powerbi \
  --status active \
  --output table

az repos pr list \
  --repository specs-dw \
  --project Trident \
  --organization https://dev.azure.com/powerbi \
  --status active \
  --output table
```

Present the results in a combined table with columns:
PR ID, Title, Repository, Author, Created Date, Status.

Ask the user which PR they want to review (by ID or title).

### Phase 2 — Describe the PR

Once a PR is selected, gather and present a comprehensive overview:

```bash
az repos pr show --id <prId> \
  --organization https://dev.azure.com/powerbi \
  --project Trident \
  --output json
```

Get the diff using the Azure DevOps REST API:

```bash
# Get an access token for Azure DevOps
TOKEN=$(az account get-access-token \
  --resource 499b84ac-1321-427f-aa17-267ca6975798 \
  --query accessToken -o tsv)

# Get PR iterations (each push to the source branch)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/pullRequests/<prId>/iterations?api-version=7.0"

# Get changes in the latest iteration
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/pullRequests/<prId>/iterations/<iterationId>/changes?api-version=7.0"

# Get the commit diff between source and target branches
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/diffs/commits?baseVersion=<targetBranch>&targetVersion=<sourceBranch>&api-version=7.0"
```

To get the actual file content at a specific version:

```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/items?path=<filePath>&versionDescriptor.version=<commitId>&versionDescriptor.versionType=commit&api-version=7.0"
```

Present a structured overview:

1. **Summary** — title, description, author, reviewers, target branch
2. **Scope** — number of files changed, insertions, deletions
3. **Files changed** — list of modified files with change type (add/edit/delete)
4. **Key changes** — brief analysis of what the code changes do

### Phase 3 — Explore & Ask Questions

The user may ask questions about the PR. Answer using the diff data already
retrieved, or fetch additional file contents as needed.

Useful commands for exploration:

```bash
# View a specific file at the source branch
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/items?path=<filePath>&versionDescriptor.version=<sourceBranch>&versionDescriptor.versionType=branch&api-version=7.0"

# View existing PR threads/comments
az repos pr thread list --id <prId> \
  --organization https://dev.azure.com/powerbi \
  --project Trident \
  --output json
```

### Phase 4 — Build Suggestions

As the user identifies issues or improvements, track each suggestion in a
local list. Do **NOT** post anything to Azure DevOps yet.

Use a SQL table to track suggestions:

```sql
CREATE TABLE IF NOT EXISTS pr_suggestions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pr_id INTEGER NOT NULL,
  file_path TEXT,
  line_start INTEGER,
  line_end INTEGER,
  category TEXT DEFAULT 'general',
  suggestion TEXT NOT NULL,
  status TEXT DEFAULT 'draft'
);
```

Categories: `bug`, `style`, `performance`, `security`, `readability`,
`architecture`, `nit`, `question`, `general`.

For each suggestion, record:
- The file path (if file-specific)
- Line range (if applicable)
- Category
- The suggestion text (what to say in the review comment)

When the user says something like "suggest that…", "note that…",
"flag this…", or "add a comment about…", insert it into the table.

Show the current suggestion count after each addition.

### Phase 5 — Review All Suggestions

When the user is ready to review (they say "review suggestions", "show me
what we have", "let's review", etc.), present ALL suggestions in a formatted
table:

```
#  | Category     | File                    | Lines   | Suggestion
---|--------------|-------------------------|---------|----------------------------
1  | bug          | src/components/Grid.tsx  | 42-45   | Null check missing on ...
2  | readability  | src/utils/format.ts      | 120     | Consider extracting ...
3  | general      | —                        | —       | The PR description ...
```

Ask the user to:
- **Approve all** suggestions for posting
- **Remove** specific suggestions (by number)
- **Edit** specific suggestions
- **Add more** suggestions

Loop until the user explicitly approves the final list.

### Phase 6 — Post Suggestions

Once approved, post each suggestion as a PR comment thread.

**For general comments** (no file context):

```bash
az repos pr thread create \
  --id <prId> \
  --description "<suggestion text>" \
  --organization https://dev.azure.com/powerbi \
  --project Trident \
  --output json
```

**For file-specific comments** (with line context):

```bash
TOKEN=$(az account get-access-token \
  --resource 499b84ac-1321-427f-aa17-267ca6975798 \
  --query accessToken -o tsv)

curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://dev.azure.com/powerbi/Trident/_apis/git/repositories/<repoName>/pullRequests/<prId>/threads?api-version=7.0" \
  -d '{
    "comments": [
      {
        "parentCommentId": 0,
        "content": "<suggestion text>",
        "commentType": 1
      }
    ],
    "status": 1,
    "threadContext": {
      "filePath": "<filePath>",
      "rightFileStart": { "line": <lineStart>, "offset": 1 },
      "rightFileEnd": { "line": <lineEnd>, "offset": 1 }
    }
  }'
```

After posting all suggestions, update their status:

```sql
UPDATE pr_suggestions SET status = 'posted'
WHERE pr_id = <prId> AND status = 'draft';
```

Report the results: how many posted successfully, any failures.

Optionally set the review vote:

```bash
# Vote values:
#   10  = approved
#    5  = approved with suggestions
#    0  = no vote
#   -5  = waiting for author
#  -10  = rejected
az repos pr set-vote --id <prId> --vote <value> \
  --organization https://dev.azure.com/powerbi \
  --project Trident
```

Ask the user what vote to set (if any) after posting suggestions.

## Quick Reference

| Action                 | Command / API                                             |
| ---------------------- | --------------------------------------------------------- |
| List PRs               | `az repos pr list --repository <repo> --status active`    |
| Show PR                | `az repos pr show --id <id>`                              |
| List threads           | `az repos pr thread list --id <id>`                       |
| Create general comment | `az repos pr thread create --id <id> --description "..."` |
| Create file comment    | REST API `POST .../threads` with `threadContext`          |
| Set vote               | `az repos pr set-vote --id <id> --vote <value>`           |
| Get access token       | `az account get-access-token --resource 499b84ac-...`     |

## Notes

- Thread status `1` = Active (use for new review comments)
- Comment type `1` = Text (regular review comment)
- Always confirm with the user before posting any comments or votes
- Never skip the review phase — all suggestions must be approved before posting
