# AGENTS.md — NixOS Configuration Flake

NixOS system configuration flake managing multiple hosts with
home-manager, sops-nix secrets, and custom overlays. All code is Nix.

## Build Commands

```bash
sudo nixos-rebuild switch --flake .#<hostname>  # Build and activate
sudo nixos-rebuild test --flake .#<hostname>     # Dry activation (no boot entry)
sudo nixos-rebuild build --flake .#<hostname>    # Build only, no activation
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel  # Eval check
nix flake update              # Update all flake inputs
nix flake update <input-name> # Update a single input
nix develop                   # Dev shell (nodejs, sops)
```

There is no test suite, linter, or `nix flake check`. The only CI is
`.github/workflows/flake-update.yml` (weekly `flake.lock` update PR).

## Formatter

**nixfmt (RFC style)**. Format files before committing:

```bash
nix fmt -- path/to/file.nix   # Format specific file(s)
nix fmt                        # Format all Nix files in the repo
```

## Repository Layout

```
flake.nix            # Root flake: inputs, nixosConfigurations, overlays, devShell, nvim package
hosts/<host>/        # Per-host: default.nix -> configuration.nix + hardware-configuration.nix
modules/             # Reusable NixOS and home-manager modules
  core/              # System foundation (flakes, fonts, gpg, locale, ssh, user, options)
  home/              # Home-manager modules (base, navi, yazi, zellij, ai, helix, etc.)
  wm/                # Window manager system modules (hyprland, sway, niri, greetd)
  niri/              # Niri compositor wrapper overlay (niri-configured, niri-dms, niri-noct)
  waybar/            # Waybar overlay with config wrapper
  rofi/              # Rofi overlay with config wrapper
  dunst/             # Dunst overlay with config wrapper
  swaylock/          # Swaylock overlay with config wrapper
  swayidle/          # Swayidle overlay with DPMS/lock logic
  noctalia/          # Noctalia shell overlay
  dms/               # DMS (Dank Material Shell) overlay
  neovim/            # Custom wrapped Neovim package builder
  secrets/           # sops-nix system secrets
  dev/               # Development compilers/runtimes
  ...                # wsl, work, syncthing, office, network, etc.
overlays/            # Package overlays (zellij-plugins, azure-cli-fix, agent-skills, agent-mcps)
secrets/             # sops-encrypted YAML secret files
```

## Hosts

| Host       | Type    | DE/WM                  | Key Modules                                             |
| ---------- | ------- | ---------------------- | ------------------------------------------------------- |
| `euler`    | Desktop | Hyprland / Sway / Niri | core, secrets, wm, office, syncthing, userland          |
| `laplace`  | Laptop  | Hyprland / Sway / Niri | core, wm, userland, syncthing, xremap, nixos-hardware   |
| `nixos`    | WSL     | --                     | core, wsl, work, dev, syncthing                         |
| `wsl-work` | WSL     | --                     | (exists on disk but not wired in flake.nix)             |

Host names follow a mathematicians convention (euler, laplace).

Both desktop hosts use `modules/wm/all.nix` for the shared WM stack: Hyprland,
Sway, and Niri sessions with greetd/tuigreet as the display manager. Per-host
overlays add Niri device configuration, waybar, rofi, dunst, swaylock, swayidle,
noctalia, and DMS wrappers.

## Module Composition

`flake.nix` composes each host by listing system modules and nesting
home-manager user modules inside `home-manager.users.miles.imports`.

Overlays are split into two tiers:
- **Global overlays** (shared by all hosts): zellij-plugins, azure-cli-fix,
  agent-skills, agent-mcps, nix-openclaw, noctalia, dms-shell, nvim, NUR
- **Per-host overlays** (euler + laplace only): niri, waybar, rofi, dunst,
  swaylock, swayidle, noctalia, dms, niri device config

### Home-Manager Modules per Host

| Module           | euler | laplace | nixos |
| ---------------- | :---: | :-----: | :---: |
| home/base        |   x   |    x    |   x   |
| home/navi        |   x   |    x    |   x   |
| home/helix       |   x   |    x    |   x   |
| home/ai          |   x   |    x    |   x   |
| home/user-space  |   x   |    x    |       |
| home/wm-common   |   x   |    x    |       |
| home/hyprland    |   x   |    x    |       |
| home/sway        |   x   |    x    |       |
| wallpapers       |   x   |    x    |       |
| home/zen-browser |   x   |    x    |       |
| home/wsl         |       |         |   x   |
| home/work        |       |         |   x   |

**Transitive imports:** `home/base` imports `home/yazi` and `home/zellij` via
`common-programs.nix`, so all hosts get yazi and zellij without listing them
directly.

## System Modules Reference

| Module             | Purpose                                                                      |
| ------------------ | ---------------------------------------------------------------------------- |
| `core/`            | Flakes, fonts, GPG, locale, SSH, user, neovim, base CLI tools                |
| `core/options.nix` | Defines `my.username` and `my.flakePath` options                             |
| `wm/all.nix`       | Shared WM stack: Hyprland, Sway, greetd/tuigreet, portals, udisks2, udiskie |
| `wm/gnome.nix`     | GDM + GNOME desktop (unused by active hosts)                                 |
| `niri/`            | Niri wrapper overlay: `niri-configured`, `niri-dms`, `niri-noct` sessions    |
| `noctalia/`        | Noctalia shell overlay                                                       |
| `dms/`             | DMS (Dank Material Shell) overlay                                            |
| `waybar/`          | Waybar overlay + config wrapper                                              |
| `rofi/`            | Rofi overlay + config wrapper                                                |
| `dunst/`           | Dunst overlay + notification config wrapper                                  |
| `swaylock/`        | Swaylock overlay + lock screen config wrapper                                |
| `swayidle/`        | Swayidle overlay + DPMS/lock idle logic                                      |
| `neovim/`          | Custom wrapped Neovim package (also exposed as `packages.nvim` / `apps.nvim`)|
| `wallpapers/`      | Copies wallpaper images into `~/Pictures/wallpapers`                         |
| `network/`         | Enables NetworkManager                                                       |
| `dev/`             | cmake, gcc, nodejs, JDK (zulu), clojure, babashka                            |
| `secrets/`         | sops-nix: TrueNAS SMB + WireGuard VPN secrets (euler only)                   |
| `wayland/`         | Shared Wayland utilities: wl-clipboard, grim, slurp (imported by wm/)        |
| `wsl/`             | NixOS-WSL integration, nix-ld, pass-secret-service, SOPS                     |
| `work/`            | Azure CLI with azure-devops + kusto extensions                               |
| `syncthing/`       | Syncthing file sync for user miles                                           |
| `office/`          | LibreOffice + Hunspell                                                       |
| `userland/`        | Logseq, Discord, Spotify                                                     |
| `nixos-tools/`     | nix-index-database + nh (rebuild helper with auto-GC)                        |
| `openclaw-node/`   | OpenClaw node host service with SOPS secrets (not wired to active hosts)     |
| `kde/`             | KDE Plasma 6, SDDM, KDE Connect (unused by active hosts)                    |
| `virtualization/`  | Docker, QEMU/KVM, virt-manager (unused by active hosts)                      |
| `wine/`            | Wine Staging + Winetricks (unused by active hosts)                           |

## Home-Manager Modules Reference

| Module              | Purpose                                                                       |
| ------------------- | ----------------------------------------------------------------------------- |
| `home/base/`        | Shell config (bash/fish/nushell), git, starship, fzf, zoxide, direnv, atuin   |
| `home/navi/`        | Navi cheatsheets (local + GitHub community cheats)                            |
| `home/helix/`       | Helix editor configuration                                                    |
| `home/ai/`          | AI tooling: copilot-cli, opencode, aider, crush, MCPs, skills, API secrets    |
| `home/wm-common/`   | Shared WM user config: dunst, rofi, swaylock, swayidle, waybar, GTK/cursor    |
| `home/hyprland/`    | Hyprland session config + hypridle/hyprlock                                   |
| `home/sway/`        | Sway session config                                                           |
| `home/yazi/`        | Yazi file manager with Catppuccin theme and zellij integration (via home/base)|
| `home/zellij/`      | Zellij multiplexer: layouts, keybinds, autolock plugin (via home/base)        |
| `home/work/`        | Overrides `my.alias.email` to corporate address + work PATH dirs              |
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

AI options (defined in `modules/home/ai/options.nix`):

- `my.ai.opencode.enable` -- OpenCode AI assistant
- `my.ai.copilot-cli.enable` -- GitHub Copilot CLI
- `my.ai.copilot-cli.notifications.enable` -- desktop notifications for copilot-cli
- `my.ai.crush.enable` -- Crush AI tool
- `my.ai.aider.enable` -- Aider AI coding assistant
- `my.ai.mcp.servers.*` -- MCP server definitions (command/url/env/headers/package)
- `my.ai.skills.*` -- Agentic skill definitions (description/content/source/license)
- `my.ai.rules.global`, `my.ai.rules.instructionFiles` -- AI instruction/rule config

Other options:

- `my.zellij.autoStart` -- auto-start zellij on shell init (defined in `modules/home/zellij/`)
- `my.openclaw-node.*` -- OpenClaw node host config including exec approval policy (defined in `modules/openclaw-node/`)

## Overlays

### File overlays (`overlays/`)

| File                     | Status | Purpose                                                 |
| ------------------------ | ------ | ------------------------------------------------------- |
| `zellij-plugins.nix`     | Active | mkZellijPlugin builder + zellij-forgot, zellij-autolock |
| `azure-cli-fix.nix`      | Active | Pins azure-cli from nixpkgs-master (temporary)          |
| `agent-skills/`          | Active | Agentic skill packages (desktop-notify, pr-review, etc.)|
| `agent-mcps/`            | Active | Agentic MCP server packages                             |
| `github-copilot-cli.nix` | Unused | Pins github-copilot-cli npm version                     |
| `calibre-8-16.nix`       | Unused | Pins Calibre 8.16.2 with tzdata deps                    |

### Input and inline overlays (wired in `flake.nix`)

| Source                        | Purpose                                                   |
| ----------------------------- | --------------------------------------------------------- |
| `nix-openclaw.overlays`       | OpenClaw packages                                         |
| `noctalia.overlays`           | Noctalia shell packages                                   |
| `niri.overlays.niri`          | Niri compositor (euler + laplace only)                    |
| `nur.overlays`                | Nix User Repository                                       |
| Inline `dms-shell`            | DMS + quickshell from dank-material-shell input            |
| Inline `nvim`                 | Wrapped Neovim from `modules/neovim`                       |
| Module overlays (per-host)    | waybar, rofi, dunst, swaylock, swayidle, noctalia, dms, niri device |

Overlays use `final: prev:` argument naming.

## Secrets (sops-nix)

- **Age keys only** (no PGP). Config in `.sops.yaml` at repo root.
- System age key: `/etc/nixos/keys.txt`
- Home-manager age key: `~/.config/sops/age/keys.txt`
- System secrets in `secrets/*.yaml` (general.yaml, wireguard.yaml, openai.yaml)
- Host-specific secrets use `.enc.yaml` suffix (e.g., `hosts/nixos/gpg-key.enc.yaml`)
- Module-local encrypted secrets:
  - `modules/home/ai/api-keys.enc.yaml` -- GitHub + SkillsMP API tokens
  - `modules/openclaw-node/gateway.enc.yaml` -- OpenClaw gateway secrets
- **Never commit unencrypted secret values.** Use `sops secrets/file.yaml` to edit.

## Key Conventions

- Every module dir has `default.nix` as entry point; composite ones are pure import aggregators
- `hardware-configuration.nix` is auto-generated -- avoid manual edits
- `system.stateVersion` / `home.stateVersion` must never change on existing hosts
