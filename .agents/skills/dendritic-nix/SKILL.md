---
name: dendritic-nix
description: Use when writing, refactoring, or reasoning about this repo's NixOS/home-manager configuration in the dendritic pattern — i.e. flake-parts + import-tree where every file under modules/ is a flake-parts module that contributes feature config across nixos/home-manager/darwin via flake.modules.<class>.<name>. Triggers on "dendritic", "add a module", "new host", "refactor into the pattern", "flake.modules", "import-tree", "aspect".
metadata:
  author: miles
  repo: ~/src/nixdots
  version: "1.0"
  sources:
    - https://github.com/mightyiam/dendritic (the pattern, README)
    - https://github.com/denful/import-tree (auto-import lib)
    - https://flake.parts + flake-parts extras/modules.nix (flake.modules option)
    - real repos: mightyiam/infra, GaetanLepage/nix-config, drupol/infra, vic/vix
---

# Dendritic Nix

How to write this repo's NixOS / home-manager config in the **dendritic pattern**.

## The one-sentence definition

> Every `.nix` file under `modules/` (except entry points) is a **flake-parts module**.
> Each file implements **one feature across every config class it applies to** (nixos + home-manager + flake outputs),
> and its **path is just a name** — files can be freely moved/renamed/split.

Read this before doing anything: the mental model is "file = feature", not "file = host" or "file = layer".

## Mandatory rules for this repo

1. **Never** add a `imports = [ ./foo.nix ./bar.nix ];` list of feature files. Auto-import (`import-tree ./modules`) loads every file. Adding a file is the only step needed to enable it.
2. Every file is a flake-parts module: `{ config, lib, inputs, self, pkgs?, ... }: { ... }`. The args are **flake-parts** args, NOT NixOS args. `pkgs` here is the flake's nixpkgs, not a host's.
3. Store lower-level (nixos / home-manager) config under the **`flake.modules.<class>.<name>`** option (provided by `flake-parts.flakeModules.modules`). Use classes `nixos`, `homeManager`, and `generic`.
4. Contribute to a feature bucket by **merging**: many files may all set `flake.modules.nixos.base = { ... };` and the module system deep-merges them. Prefer a few well-named buckets over one-bucket-per-file (see Anti-patterns).
5. A NixOS module value is a **`deferredModule`**. To get real NixOS args inside it, write a function: `flake.modules.nixos.foo = { pkgs, config, lib, ... }: { ... };`. Don't confuse these args with the flake-parts args of the outer file.
6. Hosts are assembled in `modules/hosts/<name>.nix`, which reads `config.flake.modules.nixos.*` and produces `flake.nixosConfigurations.<name>`.
7. Packages / `callPackage` files are **not** modules. Keep them out of the import tree: put them under `pkgs/` (repo root) or any path containing `/_` (import-tree ignores those). Reference them from a module.
8. Need a new flake input? Add it to `flake.nix` `inputs` and use `inputs.<name>` inside any module. (We do not use flake-file/npins here.)

## Repo layout

```
flake.nix                      # entry point: mkFlake (import-tree ./modules)
pkgs/                          # callPackage sources (NOT modules; outside import tree)
  neovim/                      # the neovim config package
modules/
  flake/                       # top-level wiring (one feature each)
    parts.nix                  # imports flake-parts.flakeModules.modules, systems, formatter
    home-manager.nix           # glue: HM-into-NixOS option/helper
  nixos/                       # nixos-class features: flake.modules.nixos.<name>
    base.nix
    audio.nix
    i3.nix
    ...
  home/                        # home-manager-class features: flake.modules.homeManager.<name>
    base.nix
    kitty.nix
    i3.nix
    ...
  packages/                    # modules that expose pkgs via overlays (e.g. nvim)
    neovim.nix
  hosts/
    euler.nix                  # flake.nixosConfigurations.euler + euler hardware
```

`flake.nix` stays tiny:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # ...other inputs
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
```

## The `flake.modules.<class>.<name>` option

It is NOT on by default. Enable it once in `modules/flake/parts.nix`:

```nix
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
  systems = [ "x86_64-linux" ];
  # optional: perSystem formatter, devshell, etc.
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;
  };
}
```

`flake.modules` has type `lazyAttrsOf (lazyAttrsOf deferredModule)`:
- outer key = module **class** (`nixos`, `homeManager`, `darwin`, or `generic`)
- inner key = feature **bucket name**
- value = a NixOS/HM module (deferredModule), **merged** across all files that target it.

`generic` modules carry no class and can be imported into any class.

## Recipes

### A nixos-only feature

```nix
# modules/nixos/audio.nix
{
  flake.modules.nixos.base = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
```

Need NixOS args (`pkgs`, `config`, `lib`)? Make the value a function:

```nix
# modules/nixos/editor.nix
{
  flake.modules.nixos.base = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.neovim ];
  };
}
```

### A home-manager-only feature

```nix
# modules/home/kitty.nix
{
  flake.modules.homeManager.base = { pkgs, ... }: {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      settings.scrollback_lines = 50000;
    };
  };
}
```

### A cross-cutting feature (nixos + home-manager in ONE file)

This is the dendritic superpower — one file owns the whole feature:

```nix
# modules/desktop/i3.nix
{
  flake.modules.nixos.i3 = { pkgs, ... }: {
    services.xserver.enable = true;
    services.xserver.windowManager.i3.enable = true;
  };
  flake.modules.homeManager.i3 = { ... }: {
    xsession.windowManager.i3.config = { /* keybindings, etc. */ };
  };
}
```

### Sharing values between files (no specialArgs plumbing)

Any file can read the top-level `config`. Declare options in **bare, per-domain
namespaces** (no `me.*`/`my.*` wrapper) and set/read them anywhere. Identity lives
in the domain that owns it; one cross-cutting `username` is the exception.

```nix
# modules/nixos/users.nix  — the one cross-cutting identity value
{ lib, config, ... }:
{
  options.username = lib.mkOption { type = lib.types.str; default = "miles"; };
  flake.modules.nixos.base.users.users.${config.username}.isNormalUser = true;
}
```

```nix
# modules/home/git.nix  — git owns its own identity options
{ lib, config, ... }:
{
  options.git = {
    userName  = lib.mkOption { type = lib.types.str;  default = "Miles Possing"; };
    userEmail = lib.mkOption { type = lib.types.str;  default = "mp-complete@pm.me"; };
  };
  flake.modules.homeManager.base.programs.git.settings.user = {
    name  = config.git.userName;
    email = config.git.userEmail;
  };
}
```

A host override is then just `git.userEmail = "work@example.com";` in that host file.

### Wiring home-manager into NixOS

home-manager is a NixOS module; pull the HM buckets in from the flake config.
Do this in ONE glue file so hosts just import `nixos.home-manager`:

```nix
# modules/flake/home-manager.nix
{ inputs, config, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.miles.imports = [
        config.flake.modules.homeManager.base
        # add more HM buckets here, or read them generically
      ];
    };
  };
}
```

Key point: `config.flake.modules.homeManager.base` is read in the **flake-parts** config (legal here) and embedded into a NixOS deferredModule. No `extraSpecialArgs` pass-through of `self` needed.

### Defining a host

```nix
# modules/hosts/euler.nix
{ inputs, config, lib, ... }:
let
  inherit (config.flake.modules.nixos) base i3 home-manager nvidia;
in
{
  flake.nixosConfigurations.euler = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      base i3 home-manager nvidia
      {
        networking.hostName = "euler";
        nixpkgs.hostPlatform = "x86_64-linux";
        # host-specific hardware (fileSystems, boot, etc.) inline or ./euler/hardware.nix
        system.stateVersion = "23.11";
      }
    ];
  };
}
```

Optional: also export the toplevel as a check:
`flake.checks.x86_64-linux.euler = config.flake.nixosConfigurations.euler.config.system.build.toplevel;`

### Packages / overlays (the one allowed exception)

`callPackage` sources live under `pkgs/` (outside the import tree). A normal module wires them via an overlay and consumes them:

```nix
# modules/packages/neovim.nix
{ inputs, ... }:
{
  flake.modules.nixos.base = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        nvim = final.callPackage ../../pkgs/neovim {
          inherit (inputs) fennel-ls-nvim-docs;
        };
      })
    ];
    environment.systemPackages = [ pkgs.nvim ];
  };
}
```

`nixpkgs.overlays` is itself merged across all files, so each package-module can add its own overlay.

## Repo conventions (decided)

These are settled choices for this repo — follow them:

1. **Import = enable.** A host opts into a feature by importing its bucket (via `mkHost`'s bucket list). Do **not**
   add `*.enable` flags that merely gate a module a host already imported. Keep options
   only where they carry real values (mcp servers, paths, identity, `skills.extra`,
   `zellij.autoStart`).
2. **Bare, per-domain option namespaces.** No `me.*`/`my.*` wrapper. Options live under
   the domain that owns them: `git.userEmail`, `skills.extra`, `ai.*`, `zellij.autoStart`.
3. **Identity is per-domain**, with a single cross-cutting `username` (declared in
   `nixos/users.nix`) and `flakePath` (in `nixos/nix-tools.nix`).
4. **GUI/user apps → home-manager `desktop` bucket**; daemons/services/hardware → nixos.

## Anti-patterns (from the dendritic README — avoid these)

- **Bucket-name proliferation.** Don't give every file its own unique `flake.modules.nixos.<uniqueName>`; that bloats every host's import list. Merge non-distinct features into shared buckets like `base`, `pc`, `desktop`. Reserve distinct names for things a host opts into individually (e.g. `i3`, `nvidia`, `hostname`).
- **Only using built-in outputs.** Prefer the explicit `flake.modules.<class>` option (with `flakeModules.modules`) over scattering raw `flake.nixosModules.<n>`. It unifies nixos + homeManager + generic and models intent.
- **`specialArgs` pass-thru.** Don't shuttle `self`/scripts through `specialArgs`/`extraSpecialArgs`. Put shared values on the top-level `config` and read them from any file.
- **Path-significant files.** A file's directory must not change its behavior. `modules/nixos/audio.nix` and `modules/audio.nix` are equivalent; the dir is for humans only.
- **Fanaticism.** The pattern allows exceptions: `callPackage` sources and large generated configs (neovim lua/fennel) live outside the tree. That's fine.

## Gotchas

- **Two arg sets.** Outer file args = flake-parts (`config`, `inputs`, `self`, `withSystem`, flake-level `pkgs`). Inner deferredModule args = NixOS/HM (`config`, `pkgs`, `lib`, `osConfig`...). When you need host `pkgs`, you MUST be inside the inner function.
- **import-tree ignores `/_`.** Name scratch/non-module files with a leading `_` (e.g. `modules/.../_helper.nix`) or keep them in `pkgs/`.
- **deferredModule merging is the whole point.** If two files set the same bucket, they merge — no `imports` needed. If you actually need ordering/priority use `lib.mkBefore`/`mkAfter`/`mkForce` as usual.
- **`config.flake.modules.X.Y` cannot be read inside that same file's own `flake.modules` imports list** if it would be self-referential; split into a `let`-binding or separate file (same caveat as flake-parts `flakeModules`).
- After edits, sanity-check with `nix flake check` or `nix eval .#nixosConfigurations.euler.config.system.build.toplevel.drvPath` — but per repo norms, don't obsess over full builds for early scaffolding.

## Quick checklist when adding a feature

1. Pick the class(es): nixos? homeManager? both?
2. Pick the bucket: shared (`base`/`pc`/`desktop`) or host-opt-in (distinct name)?
3. Create `modules/<area>/<feature>.nix` setting `flake.modules.<class>.<bucket> = ...`.
4. Need NixOS/HM args → make the value a `{ pkgs, ... }: { ... }` function.
5. Need a package → add source to `pkgs/`, wire overlay in a `modules/packages/*.nix`.
6. Done. Auto-import picks it up; no list to edit.
