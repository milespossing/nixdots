---
name: install-skill
description: How to add, remove, or update agent skills in this NixOS configuration repository.
---

# Installing Agent Skills

This repository manages OpenCode agent skills declaratively through a Nix
overlay. Skills are registered in the overlay, then assigned to hosts in
`flake.nix`. After a `nixos-rebuild switch`, each skill lands at
`~/.config/opencode/skills/<name>/SKILL.md` and is auto-discovered by OpenCode.

## Architecture

```
modules/home/ai/lib.nix              # Builder functions
overlays/agent-skills/default.nix    # Skill registry (pkgs.agenticSkills)
flake.nix                            # Per-host assignment (my.ai.skills.<name>)
```

## Builder Functions (lib.nix)

| Function                    | Use when                                      |
|-----------------------------|-----------------------------------------------|
| `mkSkillFromFile path`      | SKILL.md is stored locally in this repo        |
| `fetchSkillFromGitHubFile`  | Fetch a single SKILL.md from GitHub (lightweight) |
| `fetchSkillFromGitHub`      | Fetch from GitHub via full repo archive (use only for small repos) |
| `mkSkill { description, content, ... }` | Define a skill inline without a file |

## Adding a Skill

### Option A: Single file from GitHub (preferred for third-party skills)

Best for large repos where you only need the SKILL.md.

1. Get the commit hash:

```bash
git ls-remote https://github.com/OWNER/REPO.git refs/heads/main | cut -f1
```

2. Get the SRI hash of the raw file:

```bash
nix-prefetch-url "https://raw.githubusercontent.com/OWNER/REPO/REV/PATH/TO/SKILL.md" 2>/dev/null \
  | xargs nix hash convert --hash-algo sha256 --to sri
```

3. Add to `overlays/agent-skills/default.nix`:

```nix
my-skill = aiLib.fetchSkillFromGitHubFile {
  owner = "OWNER";
  repo = "REPO";
  rev = "COMMIT_HASH";
  path = "PATH/TO/SKILL.md";
  hash = "sha256-...";
};
```

### Option B: Local SKILL.md

Best for skills you author or want to customise.

1. Create `overlays/agent-skills/<name>/SKILL.md` with YAML frontmatter and
   markdown body.

2. Add to `overlays/agent-skills/default.nix`:

```nix
my-skill = aiLib.mkSkillFromFile ./my-skill/SKILL.md;
```

### Option C: Full repo archive from GitHub

Only use for small repos. Downloads the entire repository.

1. Get the commit hash (same as Option A step 1).

2. Get the SRI hash of the **unpacked archive**:

```bash
nix-prefetch-url --unpack "https://github.com/OWNER/REPO/archive/REV.tar.gz" 2>/dev/null \
  | xargs nix hash convert --hash-algo sha256 --to sri
```

3. Add to `overlays/agent-skills/default.nix`:

```nix
my-skill = aiLib.fetchSkillFromGitHub {
  owner = "OWNER";
  repo = "REPO";
  rev = "COMMIT_HASH";
  path = "PATH/TO/SKILL.md";
  hash = "sha256-...";
};
```

## Wiring into Hosts

After registering the skill in the overlay, assign it in `flake.nix` for each
host that should have it. Only hosts importing `modules/home/ai` support
skills (currently `laplace` and `nixos`).

```nix
my.ai.skills.<name> = pkgs.agenticSkills.<name>;
```

## Removing a Skill

1. Delete the entry from `overlays/agent-skills/default.nix`.
2. Remove every `my.ai.skills.<name>` line from `flake.nix`.
3. Delete the local directory under `overlays/agent-skills/<name>/` if one exists.

## Updating a Skill

For fetched skills, update `rev` and `hash` in `overlays/agent-skills/default.nix`.
For local skills, edit the SKILL.md file directly.

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
