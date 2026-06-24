# AGENTS.md

miles's NixOS + home-manager configuration. Read this first when working in
this repo.

## What this is

A **dendritic** Nix flake: [flake-parts](https://flake.parts) +
[import-tree](https://github.com/denful/import-tree), where **every `.nix` file
under `modules/` is a flake-parts module** that contributes one feature across
nixos / home-manager. `flake.nix` is tiny and just does
`mkFlake (import-tree ./modules)` — there is **no central list of imports**;
dropping a file under `modules/` enables it.

Mental model: **file = feature**, not file = host or file = layer. A file's
directory is for humans; it does not change behavior.

## Layout

```
flake.nix                  # mkFlake (import-tree ./modules) — entry point
modules/                   # every file is a flake-parts module (auto-imported)
  flake/                   # top-level wiring: parts, home-manager glue, wrappers,
                           #   packages, checks, secrets, overlays, devshell
  hosts/                   # flake.nixosConfigurations.<host> via mkHost
  system/ hardware/ network/ shell/ desktop/ development/ ai/ agents/
  work/ wsl/ gaming/ virtualization/ browsers/ packages/
wrappers/                  # nix-wrapper-modules wrapper bodies (NOT auto-imported;
                           #   referenced explicitly from modules/flake/wrappers.nix)
pkgs/neovim/               # the neovim config package (callPackage source)
overlays/                  # non-wrapper overlays (pi-coding-agent, pi-extensions, …)
secrets/  .sops.yaml       # sops-nix encrypted secrets
docs/                      # architecture notes + roadmap (see docs/wrappers.md)
```

Files/dirs containing `/_` (e.g. `_hardware.nix`, `_impl/`, `_skills/`) and
anything outside `modules/` are **not** auto-imported.

## The dendritic pattern (rules)

1. **Never** add an `imports = [ ./a.nix ./b.nix ]` list of feature files.
   Adding a file is the only step to enable it.
2. Each file is `{ config, lib, inputs, self, ... }: { … }` — these are
   **flake-parts** args. `pkgs` here is the flake's nixpkgs, not a host's.
3. Lower-level config goes under **`flake.modules.<class>.<bucket>`**
   (classes: `nixos`, `homeManager`). Many files merge into the same bucket
   (e.g. lots of files set `flake.modules.nixos.base`). Prefer shared buckets
   (`base`, `desktop-core`, `dev`) over one-bucket-per-file; reserve distinct
   names for host opt-ins (`i3`, `sway`, `nvidia`, `wsl`, `networkmanager`).
4. A bucket value is a **deferredModule**. To get real NixOS/HM args, make it a
   function: `flake.modules.nixos.base = { pkgs, ... }: { … };`.
5. **Share values via the top-level `config`**, not specialArgs. Declare options
   in **bare per-domain namespaces** (`git.userEmail`, `shell.aliases`,
   `skills.extra`) and read them anywhere. One cross-cutting `username`
   (`system/users.nix`) and `flakePath` are the exceptions.
6. **Import = enable.** A host opts into a feature by listing its bucket in
   `mkHost`. Do **not** add `*.enable` flags that merely gate a module a host
   already imported. Keep options only where they carry real values.

## Hosts

Assembled in `modules/hosts/<host>.nix` via the `mkHost` helper
(`modules/flake/home-manager.nix`), which pulls in both `nixos.<bucket>` and
`homeManager.<bucket>` for each bucket in the host's list.

- **euler** — i3/X11 workstation (nvidia). buckets: base hardware nvidia i3 dev
  ai skills syncthing virt wine mounts wireguard samba. Wired (`useDHCP`), no
  NetworkManager.
- **laplace** — sway/Wayland Framework laptop. buckets: base hardware
  networkmanager sway dev ai skills syncthing. The only host with wifi /
  NetworkManager.
- **nixos** — WSL work host. buckets: base dev ai skills syncthing work wsl.
  Networking handled by WSL.

## Wrappers (nix-wrapper-modules)

Config-bearing CLI/GUI tools (kitty, tmux, yazi, rofi, dunst, waybar,
swaylock-effects, hunk, worktrunk, pi-coding-agent-*) are **wrapped** and
delivered through the flake-parts `flake.wrappers` registry — **no overlay**,
consumed explicitly as `config.flake.wrappers.<n>.wrap { inherit pkgs; }`.

Full architecture, recipes, patterns (runtimePkgs, cross-refs, pi composition),
and roadmap: **see `docs/wrappers.md`**. Read it before touching anything under
`wrappers/` or `modules/flake/wrappers.nix`.

Quick rule: if a wrapper shells out to a bare command, add it to the wrapper's
`runtimePkgs` rather than relying on a global install.

## Conventions

- GUI / user apps → home-manager (`desktop-core` etc.); daemons / services /
  hardware → nixos.
- `callPackage` sources live in `pkgs/` or a `/_` path (outside the import
  tree); wire them via an overlay in a `modules/.../*.nix` file.
- Secrets: sops-nix. Never print, commit, or write decrypted secret values.
  Encrypted files are `*.enc.yaml` under the owning feature or `secrets/`.
- Format with `nix fmt` (nixfmt-tree).

## Validating changes

```sh
nix flake check                                   # builds every host toplevel (+ wrappers)
nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath   # fast eval-only
nix build .#<wrapper>                             # build one wrapper (e.g. .#kitty, .#pi-coding-agent-wsl)
nh os switch                                      # apply (programs.nh)
```

The flake is git-based: `nix` only sees **git-tracked** files. After creating a
new file, `git add` it (or `git add -N`) before evaluating, or it's invisible.

## Skills

Task-specific guidance lives in `.agents/skills/` — load the relevant `SKILL.md`:

- **dendritic-nix** — writing/refactoring modules in this pattern (read for any
  structural change).
- **kitty-config**, **pi-extensions**, **pi-startup-profiling**, **upgrade-pi**.
