---
name: pi-extensions
description: Use when the user wants to add, package, update, or remove a pi-coding-agent extension — e.g. "add the npm package X as a pi extension", "package this pi extension", "bump the pi-wsl-images extension". Covers the overlays/pi-extensions registry, the wrappers/pi bundle, and host wiring. Do not load for general pi usage, MCP servers, or other agents (opencode/copilot/crush/aider).
metadata:
  author: miles
  repo: ~/.config/nixos
  version: "1.0"
---

# Packaging pi extensions in the nixos flake

In this repo, "a pi extension" is a Nix derivation whose output is an
unpacked pi-package directory (a `package.json` with a `pi` manifest,
plus its `src/`, `skills/`, `prompts/`, `themes/` …). The pi wrapper
loads each one with a `--extension <store-path>` flag.

There are exactly three files involved. Touch only what the task needs:

| File                                       | Role                                                            |
| ------------------------------------------ | --------------------------------------------------------------- |
| `overlays/pi-extensions/default.nix`       | The registry. Builds each extension into `pkgs.piExtensions.*`. |
| `wrappers/pi/pi-wsl.nix`                    | The bundle. Lists which extensions ship in `pi-coding-agent-wsl` / `nix run .#pi-wsl`. |
| `flake.nix` (`my.ai.pi.extensions`)        | Per-host opt-in for the installed pi (separate from the `-wsl` bundle). |

Local (git/in-tree, not-on-npm) extensions additionally live under
`wrappers/pi/extensions/<name>/` and are registered in
`wrappers/pi/module.nix`'s overlay.

## Procedure: add an npm-published extension

This is the common case (e.g. `@scope/pkg-name` on npmjs.com).

### 1. Fetch the package metadata

Get the latest version and the SRI integrity hash straight from the
registry — `dist.integrity` is already in the `sha512-…` SRI format that
`fetchurl` wants, so no `nix-prefetch` round-trip is needed:

```bash
PKG='@milespossing/pi-copilot-discovery'
curl -s "https://registry.npmjs.org/$PKG" \
  | jq -r '.["dist-tags"].latest as $v
           | "version: \($v)\nhash:    \(.versions[$v].dist.integrity)\ndeps:    \(.versions[$v].dependencies)\npi:      \(.versions[$v].pi)"'
```

Note:

- **`deps`** — if it prints `null` (no runtime deps), omit `npmDepsHash`
  below (the simple, fast path). If it lists deps, see "Extensions with
  npm deps".
- **`pi`** — confirm the package actually has a `pi` manifest
  (`extensions`/`skills`/`prompts`/`themes`). If it's missing, the package
  isn't a pi extension and pi won't load anything from it.

### 2. Register it in the overlay

Add an entry to the `piExtensions` attrset in
`overlays/pi-extensions/default.nix`, alphabetically near its peers, with
a comment giving the homepage and a one-line description:

```nix
# @milespossing/pi-copilot-discovery — dynamic GitHub Copilot model
# discovery for pi. Replaces pi-ai's static catalog with the live
# /models list from your Copilot tenant.
# https://github.com/milespossing/pi-copilot-discovery
pi-copilot-discovery = mkPiExtensionFromNpm {
  pname = "@milespossing/pi-copilot-discovery";
  version = "0.1.0";
  hash = "sha512-…";  # the dist.integrity from step 1
};
```

The attribute name is the unscoped, registry-friendly short name (drop the
`@scope/`). Add `meta.platforms = lib.platforms.linux;` only for
WSL/Linux-specific extensions.

### 3. Wire it where it should load

- To ship it in the WSL bundle (`nix run .#pi-wsl`), add the attr name to
  the `extensions` list in `wrappers/pi/pi-wsl.nix` with a trailing
  `# one-line` comment matching the existing style.
- To enable it on an installed host's pi, add
  `pkgs.piExtensions.<name>` to that host's `my.ai.pi.extensions` list in
  `flake.nix`. These two lists are independent — set both if the user
  wants it everywhere.

### 4. Format and verify

```bash
nix fmt -- overlays/pi-extensions/default.nix wrappers/pi/pi-wsl.nix
nix build --no-link .#pi-wsl        # builds the bundle = fetches + unpacks the new ext
```

A successful build proves the `hash` is correct and the tarball unpacks.
If you only touched a host's `my.ai.pi.extensions`, eval that host instead:
`nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.

To double-check the unpacked layout carries a `pi` manifest:

```bash
ext=$(nix-store -q --references "$(nix build --no-link --print-out-paths .#pi-wsl)" \
        | grep <name> | head -1)
jq '{name, version, pi}' "$ext/package.json"
```

## Extensions with npm deps

If step 1 showed runtime `dependencies`, the simple `runCommand` unpack
won't include `node_modules`. Pass `npmDepsHash` so `buildNpmPackage`
installs them. Get the hash by building once with a fake hash and copying
the "got:" value from the error (`lib.fakeHash`), then rebuild:

```nix
my-ext = mkPiExtensionFromNpm {
  pname = "@scope/my-ext";
  version = "1.2.3";
  hash = "sha512-…";       # tarball integrity
  npmDepsHash = "sha256-…"; # node_modules deps hash
};
```

## Local / in-tree extensions (not on npm)

For an extension authored in this repo (no npm publish), follow the
existing `agent-browser-edge-bridge` pattern:

1. Put sources under `wrappers/pi/extensions/<name>/` with a
   `package.json` (`pi` manifest), `src/`, and a `default.nix` that
   `runCommand`s the filtered fileset into a pi-package layout (set
   `passthru.piExtension = true`).
2. Register it in `wrappers/pi/module.nix`'s overlay:
   `piExtensions = (prev.piExtensions or {}) // { <name> = final.callPackage ./extensions/<name> {}; };`
3. Add it to the bundle / host lists exactly like an npm one.

## Updating or removing an extension

- **Bump a version:** re-run step 1 for the new version, then update both
  `version` and `hash` in the overlay entry. Rebuild to confirm.
- **Remove:** delete the overlay entry and every reference to its attr
  name in `wrappers/pi/pi-wsl.nix` and `flake.nix`. Rebuild.

## Reference: how the wiring fits together

- `mkPiExtensionFromNpm` (defined in `overlays/pi-extensions/default.nix`)
  derives the tarball URL from `pname`/`version`, fetches it with the SRI
  `hash`, and unpacks it (`runCommand`) or runs `buildNpmPackage` when
  `npmDepsHash` is set.
- `wrappers/pi/module.nix` turns the `extensions` list into repeated
  `--extension <path>` flags on the wrapped pi binary.
- `wrappers/pi/pi.nix` is the baseline wrap (runtime PATH tools);
  `pi-wsl.nix` is a second `.wrap` that only adds the extension bundle.
- The `my.ai.pi.extensions` option (in `modules/home/ai/options.nix`,
  consumed by `modules/home/ai/pi.nix`) re-wraps `pkgs.pi-coding-agent`
  with the host's chosen extensions.
