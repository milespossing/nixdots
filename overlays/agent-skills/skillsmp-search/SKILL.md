---
name: skillsmp-search
description: Search the SkillsMP marketplace for agent skills. Use when the user wants to find, discover, or browse skills from the SkillsMP catalog — e.g. "find a skill for X", "search skillsmp", "are there skills for Y", or when recommending skills to install.
---

# SkillsMP Search

Search the [SkillsMP](https://skillsmp.com) marketplace for agent skills.
SkillsMP indexes SKILL.md files from public GitHub repositories and provides
a search API over the catalog.

## Authentication

All requests require a Bearer token via the `SKILLSMP_API_KEY` environment variable.

```
Authorization: Bearer $SKILLSMP_API_KEY
```

If the variable is not set, tell the user to set `SKILLSMP_API_KEY` and stop.

## Rate Limits

- **500 requests/day** (hard cap)
- **30 requests/minute** (burst cap)
- Headers `x-ratelimit-daily-remaining` and `x-ratelimit-minute-remaining` are
  returned on every response. Check these and warn the user if running low.
- Be conservative: avoid redundant or speculative searches. Prefer a single
  well-targeted query over multiple exploratory ones.

## Endpoint

```
GET https://skillsmp.com/api/v1/skills/search
```

### Query Parameters

| Param    | Type   | Required | Default  | Notes                                          |
|----------|--------|----------|----------|-------------------------------------------------|
| `q`      | string | yes      | —        | Free-text search query. Searches name, description, and author. |
| `limit`  | int    | no       | 20       | Results per page. Max 50.                       |
| `page`   | int    | no       | 1        | Page number for pagination.                     |
| `sortBy` | string | no       | `recent` | Sort order. Known values: `recent`, `stars`.    |

### Example Request

```bash
curl -s \
  -H "Authorization: Bearer $SKILLSMP_API_KEY" \
  "https://skillsmp.com/api/v1/skills/search?q=nix&sortBy=stars&limit=5"
```

### Response Shape

```json
{
  "success": true,
  "data": {
    "skills": [
      {
        "id": "owner-repo-path-skill-md",
        "name": "skill-name",
        "author": "GitHubUsername",
        "description": "What the skill does and when to use it.",
        "githubUrl": "https://github.com/owner/repo/tree/branch/path/to/skill",
        "skillUrl": "https://skillsmp.com/skills/<id>",
        "stars": 123,
        "updatedAt": "1773723654"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 5,
      "total": 21,
      "totalPages": 5,
      "hasNext": true,
      "hasPrev": false,
      "totalIsExact": false
    },
    "filters": {
      "search": "nix",
      "sortBy": "stars"
    }
  },
  "meta": {
    "requestId": "uuid",
    "responseTimeMs": 5
  }
}
```

### Error Responses

| Code               | Meaning                                |
|--------------------|----------------------------------------|
| `MISSING_API_KEY`  | No `Authorization` header provided.    |
| `MISSING_QUERY`    | The `q` parameter was not supplied.    |

### Field Notes

- `id` — deterministic, derived from the GitHub path. Not useful for fetching
  individual skills (there is no get-by-ID endpoint).
- `stars` — GitHub stars of the **repository** (not the skill). Useful as a
  rough quality signal, but a repo with 9000 stars may contain a trivial test
  SKILL.md.
- `updatedAt` — Unix timestamp (seconds). Reflects when SkillsMP last indexed
  the skill, not necessarily when the skill content changed.
- `totalIsExact` — always `false` in practice; `total` is an approximation
  that grows as you paginate. Do not rely on it for exact counts.
- `githubUrl` — points to the skill's directory on GitHub. The actual SKILL.md
  is at `<githubUrl>/SKILL.md` (the file, not the directory).

## How to Use Results

When presenting results to the user:

1. Show the skill **name**, **author**, **description**, and **stars**.
2. Include the `githubUrl` so the user can inspect the SKILL.md source.
3. If the user wants to install a skill into this NixOS config, they need:
   - The GitHub `owner` and `repo` (parse from `githubUrl`)
   - The `rev` (commit hash — not available from SkillsMP, must be looked up)
   - The path to `SKILL.md` within the repo
   - A Nix hash (obtained via `nix-prefetch-url --unpack`)
   These go into a `fetchSkillFromGitHub` call in `overlays/agent-skills/default.nix`.
