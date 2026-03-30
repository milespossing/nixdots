# AGENTS.md — NixOS Configuration Flake

NixOS system configuration flake managing multiple hosts with
home-manager, sops-nix secrets, and custom overlays. All code is Nix.

## Build Commands

```bash
sudo nixos-rebuild switch --flake .#<hostname>  # Build and activate
sudo nixos-rebuild test --flake .#<hostname>     # Dry activation (no boot entry)
sudo nixos-rebuild build --flake .#<hostname>    # Build only, no activation
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel --no-build  # Eval check
nix flake update              # Update all flake inputs
nix flake update <input-name> # Update a single input
nix develop                   # Dev shell (nodejs, sops)
```

There is no test suite, linter, or `nix flake check`. The only CI is
`.github/workflows/flake-update.yml` (weekly `flake.lock` update PR).

## Formatter

**nixfmt (RFC style)**. Run `nixfmt` on any file you modify before committing.

## Repository Layout

```
flake.nix            # Root flake: inputs, nixosConfigurations, overlays, devShell
hosts/<host>/        # Per-host: default.nix -> configuration.nix + hardware-configuration.nix
modules/             # Reusable NixOS and home-manager modules
  core/              # System foundation (flakes, fonts, gpg, locale, ssh, user, options)
  home/              # Home-manager modules (base, navi, yazi, zellij, ai, etc.)
  secrets/           # sops-nix system secrets
  dev/               # Development compilers/runtimes
  ...                # kde, wayland, wsl, work, syncthing, office, etc.
overlays/            # Package overlays
secrets/             # sops-encrypted YAML secret files
```

## Hosts

| Host       | Type    | DE/WM | Key Modules                                       |
| ---------- | ------- | ----- | ------------------------------------------------- |
| `euler`    | Desktop | KDE   | core, secrets, kde, office, syncthing, userland   |
| `laplace`  | Laptop  | GNOME | core, userland, syncthing, xremap, nixos-hardware |
| `nixos`    | WSL     | --    | core, wsl, work, dev, syncthing                   |
| `wsl-work` | WSL     | --    | (exists on disk but not wired in flake.nix)       |

Host names follow a mathematicians convention (euler, laplace).

## Module Composition

`flake.nix` composes each host by listing system modules and nesting
home-manager user modules inside `home-manager.users.miles.imports`.
Overlays are applied per-host in `flake.nix`, not globally.

### Home-Manager Modules per Host

| Module           | euler | laplace | nixos |
| ---------------- | :---: | :-----: | :---: |
| home/base        |   x   |    x    |   x   |
| home/navi        |   x   |    x    |   x   |
| home/ai          |       |    x    |   x   |
| home/user-space  |   x   |    x    |       |
| home/zen-browser |   x   |    x    |       |
| home/wsl         |       |         |   x   |
| home/work        |       |         |   x   |

## System Modules Reference

| Module             | Purpose                                                       |
| ------------------ | ------------------------------------------------------------- |
| `core/`            | Flakes, fonts, GPG, locale, SSH, user, neovim, base CLI tools |
| `core/options.nix` | Defines `my.username` and `my.flakePath` options              |
| `dev/`             | cmake, gcc, nodejs, JDK, clojure, babashka                    |
| `secrets/`         | sops-nix: TrueNAS SMB + WireGuard VPN secrets (euler only)    |
| `kde/`             | KDE Plasma 6, SDDM, KDE Connect, GNOME Keyring                |
| `wayland/`         | wl-clipboard, grim, slurp (imported by kde/)                  |
| `wm/gnome.nix`     | GDM + GNOME desktop (laplace)                                 |
| `wsl/`             | NixOS-WSL integration, sops-nix, GNOME Keyring, libsecret     |
| `work/`            | Azure CLI with azure-devops extension                         |
| `syncthing/`       | Syncthing file sync for user miles                            |
| `office/`          | LibreOffice + Hunspell                                        |
| `userland/`        | Logseq, Discord, Spotify                                      |
| `nixos-tools/`     | nix-index-database + nh (rebuild helper with auto-GC)         |
| `virtualization/`  | Docker, QEMU/KVM, virt-manager (unused by active hosts)       |
| `wine/`            | Wine Staging + Winetricks (unused by active hosts)            |

## Home-Manager Modules Reference

| Module              | Purpose                                                                       |
| ------------------- | ----------------------------------------------------------------------------- |
| `home/base/`        | Shell config (bash/fish/nushell), git, starship, fzf, zoxide, direnv, atuin   |
| `home/navi/`        | Navi cheatsheets (local + GitHub community cheats)                            |
| `home/yazi/`        | Yazi file manager with Catppuccin theme and zellij integration                |
| `home/zellij/`      | Zellij multiplexer: layouts (ide/copilot/opencode/explore), keybinds, plugins |
| `home/ai/`          | github-copilot-cli, opencode                                                  |
| `home/work/`        | Overrides `my.alias.email` to corporate address                               |
| `home/wsl/`         | Nerd Fonts, GPG + pass, git-credential-manager, WSL utilities                 |
| `home/user-space/`  | Kitty terminal (DepartureMono + Catppuccin Mocha)                             |
| `home/zen-browser/` | Zen Browser (Firefox-based, from flake input)                                 |

## Custom Options

System-level options are namespaced under `my.` (defined in `modules/core/options.nix`):

- `my.username` -- primary user (default: `"miles"`)
- `my.flakePath` -- path to this flake on disk

Home-manager options (defined in `modules/home/base/options.nix` and `shells.nix`):

- `my.alias.name`, `my.alias.email` -- git identity
- `shell.aliases`, `shell.initExtra`, `shell.pathDirs`, `shell.envExtra` -- shared shell config

## Overlays

| File                     | Status | Purpose                                                 |
| ------------------------ | ------ | ------------------------------------------------------- |
| `zellij-plugins.nix`     | Active | mkZellijPlugin builder + zellij-forgot, zellij-autolock |
| `azure-cli-fix.nix`      | Active | Pins azure-cli from nixpkgs-master (temporary)          |
| `github-copilot-cli.nix` | Unused | Pins github-copilot-cli npm version                     |
| `calibre-8-16.nix`       | Unused | Pins Calibre 8.16.2 with tzdata deps                    |

Only `zellij-plugins.nix` and `azure-cli-fix.nix` are wired in `flake.nix`.
Overlays use `final: prev:` argument naming.

## Secrets (sops-nix)

- **Age keys only** (no PGP). Config in `.sops.yaml` at repo root.
- System age key: `/etc/nixos/keys.txt`
- Home-manager age key: `~/.config/sops/age/keys.txt`
- System secrets in `secrets/*.yaml` (general.yaml, wireguard.yaml, openai.yaml)
- Host-specific secrets use `.enc.yaml` suffix (e.g., `hosts/nixos/gpg-key.enc.yaml`)
- **Never commit unencrypted secret values.** Use `sops secrets/file.yaml` to edit.

## Key Conventions

- Every module dir has `default.nix` as entry point; composite ones are pure import aggregators
- `hardware-configuration.nix` is auto-generated -- avoid manual edits
- `system.stateVersion` / `home.stateVersion` must never change on existing hosts
