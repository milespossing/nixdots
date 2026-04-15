# Creating Sway and Hyprland Wrapper Modules

## Goal

Port the existing sway and hyprland configurations to the same layered wrapper pattern used by niri. Each WM should produce per-shell variants (waybar, noctalia, dms) as wrapped packages with proper greeter session entries — no home-manager config involved.

## How the Niri Pattern Works

The niri module lives at `modules/niri/` and uses [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) (`wlib`) to produce wrapped niri binaries with baked-in config. The config is composed in three layers using `.apply` and `.wrap`:

### Layer 1: Core (`modules/niri/core.nix`)

Returns a **wlib config object** (not a package) by calling `.apply` on the base wrapper module. This contains everything compositor-specific but shell/device-agnostic:

- Input, cursor, layout, animations
- Workspaces, keybinds, window rules
- Common startup daemons (clipboard, polkit, wallpaper daemon — but **not** any bar)
- Utility scripts (screenshot, color picker, wallpaper cycle)

```nix
{ pkgs, wlib }:
let
  niriBase = (wlib.evalModule wlib.wrapperModules.niri).config;
in
niriBase.apply {
  inherit pkgs;
  v2-settings = true;
  settings = {
    # ... all the core config
  };
}
```

The key detail: `.apply` returns a **config object** that has `.wrap` and `.wrapper` on it. This is what allows the next layers to extend it.

### Layer 2: Shell variants (`modules/niri/shells/*.nix`)

Each shell file imports core and calls `.wrap` to add the bar's `spawn-at-startup`:

```nix
# shells/waybar.nix
{ pkgs, wlib }:
let
  core = import ../core.nix { inherit pkgs wlib; };
in
core.wrap {
  settings.spawn-at-startup = [
    "${pkgs.waybar}/bin/waybar"
  ];
}
```

`.wrap` takes a module (or attrset of settings) and returns a **package** (derivation). So after this layer, we have an actual wrapped niri binary.

Three shell variants exist:
- `shells/waybar.nix` — spawns waybar
- `shells/noctalia.nix` — spawns noctalia-shell
- `shells/dms.nix` — spawns dms-shell (Dank Material Shell)

### Layer 3: Device config (`hosts/*/niri-device.nix`)

Per-host overrides for outputs (monitors) and environment variables. These are plain attrsets (not functions — they're passed as wlib modules):

```nix
# hosts/euler/niri-device.nix
{
  settings = {
    environment = {
      LIBVA_DRIVER_NAME = "nvidia";
      # ...
    };
    outputs = {
      "DP-2" = { ... };
      "DP-1" = { ... };
    };
  };
}
```

### Assembly (`modules/niri/default.nix`)

`mkOverlays` ties everything together as a nixpkgs overlay:

```nix
mkOverlays = wlib: { deviceModule }: final: prev:
  let
    mkShell = shellFile:
      let shell = import shellFile { pkgs = final; inherit wlib; };
      in shell.wrap deviceModule;  # shell.wrap returns a package
    mkSession = import ./mkSession.nix;
  in {
    niri-configured = mkSession { pkgs = final; wrapped = mkShell ./shells/waybar.nix; name = "niri-configured"; displayName = "Niri"; };
    niri-dms       = mkSession { pkgs = final; wrapped = mkShell ./shells/dms.nix;    name = "niri-dms";        displayName = "Niri DMS"; };
    niri-noct      = mkSession { pkgs = final; wrapped = mkShell ./shells/noctalia.nix; name = "niri-noct";     displayName = "Niri Noctalia"; };
  };
```

### Session entries (`modules/niri/mkSession.nix`)

This is **compositor-agnostic** and can be reused for sway/hyprland. It takes any wrapped WM package and:

1. Creates a session startup script that does systemd environment setup, then execs the wrapped binary with `--session`
2. Creates a `.desktop` file pointing to that script
3. Strips the upstream `share/wayland-sessions/` and `share/systemd/` from the wrapped package to avoid conflicts

**Critical lesson learned:** Multiple variants can't share the same systemd service filename (`niri.service`). The upstream `niri-session` script delegates to `systemctl --user start niri.service`, so whichever variant's service file wins the merge dictates all sessions. `mkSession` avoids this by running the wrapped binary directly.

The session script in mkSession.nix currently hardcodes niri-specific bits:
- The `niri.service` check (`systemctl --user -q is-active niri.service`)
- The `--session` flag
- The `niri-shutdown.target`
- The env vars to unset (`NIRI_SOCKET`, etc.)

**You'll need to either generalize mkSession or create per-WM session scripts.** Sway and Hyprland have different session startup patterns.

## What Exists for Sway and Hyprland

### No upstream wlib wrapper modules

Unlike niri, there are **no `wlib.wrapperModules.sway` or `wlib.wrapperModules.hyprland`** in nix-wrapper-modules. You have two options:

1. **Use `wlib.modules.default`** to create a generic wrapper (like `modules/dunst/dunst.nix` does) — write a config file and pass it via flags/env
2. **Contribute wrapper modules upstream** to nix-wrapper-modules (preferred long-term)

### Current sway config (`modules/home/sway/sway.nix`)

Uses the home-manager `wayland.windowManager.sway` module. Config is Nix-native (attrsets). Key things to port:

- **Config format:** i3/sway config syntax (not KDL). Sway reads from `~/.config/sway/config` or a path passed via `sway -c <path>`
- **Startup:** `config.startup` list — includes waybar, nm-applet, clipboard, polkit, wallpaper
- **Keybinds:** `config.keybindings` attrset
- **Window rules:** `config.window.commands` list
- **Modes:** `config.modes` (resize, launch submaps)
- **SwayFX extras:** `extraConfig` string with shadows, blur, corner_radius, layer_effects
- **Nvidia env vars:** `extraSessionCommands` (euler only, overridden on laplace)
- **Monitor config:** in `hosts/*/sway-monitors.nix` via `config.output` and `workspaceOutputAssign`

Sway wrapper approach: generate a config file string, use `wlib.modules.default` to wrap `pkgs.swayfx` with `--config <store-path>` flag.

### Current hyprland config (`modules/home/hyprland/hyprland.nix`)

Uses the home-manager `wayland.windowManager.hyprland` module. Config is Nix-native.

- **Config format:** Hyprland's custom format. Reads from `~/.config/hypr/hyprland.conf` or `HYPRLAND_CONFIG`
- **Startup:** `exec-once` list
- **Keybinds:** `bind`, `bindm`, `bindl`, `bindel` lists (string-format dispatch commands)
- **Window rules:** `windowrule` list
- **Submaps:** In `extraConfig` string
- **Monitor config:** in `hosts/*/monitors.nix` via `settings.monitor` list
- **Nvidia env vars:** in `settings.env`, overridden on laplace via `mkForce`

Hyprland wrapper approach: generate a config file string, use `wlib.modules.default` to wrap `pkgs.hyprland` with env var `HYPRLAND_CONFIG=<store-path>`.

## What You Need to Build

For each of sway and hyprland, create:

```
modules/sway/
  core.nix           # Layer 1: core compositor config (no bar, no device specifics)
  shells/
    waybar.nix       # Layer 2: wraps core, adds waybar startup
    noctalia.nix     # Layer 2: wraps core, adds noctalia-shell startup
    dms.nix          # Layer 2: wraps core, no bar
  mkSession.nix      # Session entry creator (or reuse/generalize niri's)
  default.nix        # Exposes mkOverlays

modules/hyprland/
  core.nix
  shells/
    waybar.nix
    noctalia.nix
    dms.nix
  mkSession.nix
  default.nix
```

And per-host device modules:
```
hosts/euler/sway-device.nix      # Monitor outputs, nvidia env, workspace assignments
hosts/euler/hyprland-device.nix  # Monitor config, nvidia env
hosts/laplace/sway-device.nix    # AMD overrides
hosts/laplace/hyprland-device.nix
```

### Sway core.nix approach

Since there's no `wlib.wrapperModules.sway`, use the generic wrapper:

```nix
{ pkgs, wlib }:
let
  swayConfig = pkgs.writeText "sway-config" ''
    # Generated sway config
    set $mod Mod4
    set $term ${pkgs.kitty}/bin/kitty
    # ... full sway config as a string ...
  '';
in
(wlib.wrapModule ({ config, ... }: {
  package = pkgs.swayfx;
  flags."--config" = swayConfig;
})).apply { inherit pkgs; }
```

Or, if you prefer Nix-native sway config generation, write a function that converts an attrset to sway config format and use `pkgs.writeText` to produce the config file.

### Hyprland core.nix approach

Similar, but with `HYPRLAND_CONFIG` env var:

```nix
{ pkgs, wlib }:
let
  hyprConf = pkgs.writeText "hyprland.conf" ''
    # Generated hyprland config
    $mod = SUPER
    # ...
  '';
in
(wlib.wrapModule ({ config, ... }: {
  package = pkgs.hyprland;
  env.HYPRLAND_CONFIG = hyprConf;
})).apply { inherit pkgs; }
```

### Session scripts differ per WM

Each WM has different session lifecycle:

**Sway:** `sway` itself handles the session. The session script just needs to exec sway with the right config. Sway handles its own `WAYLAND_DISPLAY` setup, UWSM, etc. You can likely just exec the wrapped sway binary directly.

**Hyprland with UWSM:** Currently uses `withUWSM = true` in the NixOS module. UWSM wraps hyprland for systemd session management. The session script might need to go through `uwsm start hyprland-session` or similar, depending on whether you want to keep UWSM integration.

**Hyprland without UWSM:** Similar to sway — just exec the wrapped binary. But you lose proper systemd integration for user services.

### Wiring into flake.nix

Add the new modules alongside niri in the `nixosConfigurations` overlay lists:

```nix
(swayModule.mkOverlays wlib {
  deviceModule = import ./hosts/euler/sway-device.nix;
})
(hyprlandModule.mkOverlays wlib {
  deviceModule = import ./hosts/euler/hyprland-device.nix;
})
```

And install them in `modules/wm/all.nix`:

```nix
environment.systemPackages = with pkgs; [
  (lib.hiPrio niri-configured)
  niri-dms
  niri-noct
  sway-configured    # new
  sway-dms           # new
  hyprland-configured # new
  # etc.
];
```

### Cleanup after porting

Once sway and hyprland are wrapped, the following home-manager modules become dead code and can be removed:

- `modules/home/sway/` — replaced by `modules/sway/`
- `modules/home/hyprland/` — replaced by `modules/hyprland/`
- `hosts/*/monitors.nix` — replaced by `hosts/*/hyprland-device.nix`
- `hosts/*/sway-monitors.nix` — replaced by `hosts/*/sway-device.nix`

The imports in the `home-manager.users.miles.imports` lists in `flake.nix` for these modules should also be removed.

## Key References

- **nix-wrapper-modules docs:** https://birdeehub.github.io/nix-wrapper-modules/
- **wlib.wrapModule:** Evaluates a module with `wlib.modules.default`, returns `.config` so `.apply`/`.wrap` are accessible
- **wlib.evalPackage:** Evaluates a module list, returns the final wrapped derivation directly
- **wlib.modules.default:** The base wrapper module — provides `flags`, `env`, `constructFiles`, etc.
- **Niri wrapper module source:** https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/wrapperModules/n/niri/module.nix
- **Formatter:** `nix fmt` (nixfmt-tree). Run before committing.
- **Eval check:** `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel`
- **Build check:** `nix build .#nixosConfigurations.<host>.pkgs.<pkg-name> --no-link --print-out-paths` then inspect the store path

## Gotchas

1. **New files must be `git add`ed** before `nix eval` can see them (flake requires tracked files)
2. **`.apply` returns config, `.wrap` returns a package** — don't mix them up
3. **Overlays use `final: prev:`** naming convention in this repo
4. **`_: { }` in KDL settings** means "a node with just a name, no children or props" — this is niri/KDL-specific and won't apply to sway/hyprland
5. **The `mkSession.nix` session script** currently has niri-specific service names (`niri.service`, `niri-shutdown.target`) — generalize or create per-WM versions
6. **Catppuccin Mocha** is the theme across all WMs — keep colors consistent
7. **`programs.sway.enable` and `programs.hyprland.enable`** in `modules/wm/all.nix` handle the NixOS-level WM setup (portals, PAM, greetd). These remain separate from the wrapper modules.
