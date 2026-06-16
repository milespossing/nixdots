---
name: upgrade-pi
description: Pin pi-coding-agent to a newer upstream release in this nixos flake. Invoke explicitly with /skill:upgrade-pi.
disable-model-invocation: true
metadata:
  author: miles
  repo: ~/.config/nixos
  version: "1.0"
---

# Upgrade pinned pi-coding-agent version

nixpkgs lags behind upstream pi releases. This repo pins a newer version
via `overlays/pi-coding-agent.nix`, which `overrideAttrs` the nixpkgs
`pi-coding-agent` with a fresh `src` + `npmDeps` hash. The build itself
(buildPhase, postInstall, …) is reused from nixpkgs unchanged.

The target version comes from the user (e.g. "upgrade pi to 0.79.4").

## Procedure

### 1. Get the source hash

```bash
V=0.79.4   # the requested version
nix-prefetch-url --unpack \
  "https://github.com/earendil-works/pi/archive/refs/tags/v$V.tar.gz" \
  | tail -1 | (read h; nix hash convert --hash-algo sha256 "$h")
```

### 2. Update the overlay

Edit `overlays/pi-coding-agent.nix`: set `version`, the src `hash` (from
step 1), and reset the `npmDeps` `outputHash` to a fake placeholder so the
build reports the real one:

```nix
outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

If the overlay doesn't exist yet, create it overriding
`prev.pi-coding-agent` (version + `src` via `fetchFromGitHub` + `npmDeps`
via `old.npmDeps.overrideAttrs { inherit src; outputHash = …; }`) and wire
`(import ./overlays/pi-coding-agent.nix)` into **both** overlay lists in
`flake.nix` (the per-system `eachDefaultSystem` list and the
`nixosConfigurations` list), ordered before `(wrappers.overlay wlib)`.

### 3. Get the npmDeps hash from the build

New files must be `git add`ed or Nix can't see them (flake = git tree).

```bash
git add overlays/pi-coding-agent.nix
nix build --no-link .#pi 2>&1 | tail -20
```

Copy the `got:` hash from the "hash mismatch in fixed-output derivation"
error into the overlay's `outputHash`, replacing the placeholder.

### 4. Verify

```bash
nix fmt -- overlays/pi-coding-agent.nix flake.nix
nix build --no-link .#pi && nix eval --raw .#packages.x86_64-linux.pi.version
nix build --no-link .#pi-wsl   # extension bundle still builds
```

The version eval must print the requested version.

## Notes

- Once nixos-unstable ships this version, the override can be deleted (and
  its two `flake.nix` references removed).
- Only `src` and `npmDeps` change between bumps; everything else in the
  overlay stays put.
