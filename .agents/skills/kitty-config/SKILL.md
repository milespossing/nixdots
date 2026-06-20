---
name: kitty-config
description: Use when the user wants to configure kitty (kitty.conf, keybindings, fonts, themes, layouts, sessions, shell integration, or remote control) in this repo. Covers both kitty-native config syntax and Nix/Home-Manager wiring.
metadata:
  author: miles
  repo: ~/.config/nixos
  version: "1.0"
  sources:
    - kitty 0.47.1 local docs (_sources/*.rst.txt)
    - kitty sample config (generated kitty.conf)
---

# Configure kitty

Use this skill for any kitty setup/update task.

## Scope and source of truth

1. Confirm whether the user wants:
   - Declarative config in Nix/Home-Manager (preferred in this repo), or
   - Direct `kitty.conf` edits (imperative/user-local).
2. For repo changes, keep config in Nix modules and generate kitty config text from Nix.
3. Keep kitty config modular (use `include`, `globinclude`, `envinclude`, `geninclude`) instead of one giant file.

## Kitty config workflow (from docs)

1. Start from defaults and inspect current behavior:
   - `kitty --debug-config` (or kitty action `debug_config`)
   - reload via `SIGUSR1` (`kill -SIGUSR1 <kitty-pid>`) or `reload_config_file`
2. Organize config by topic with includes, e.g.:
   - `kitty.conf`
   - `kitty.d/fonts.conf`
   - `kitty.d/colors.conf`
   - `kitty.d/keys.conf`
3. Use kittens for interactive tuning:
   - `kitten choose-fonts` for font selection/features
   - `kitten themes` for color theme selection
4. Validate keymaps with:
   - `kitty --debug-input`
   - `kitten show-key -m kitty`
5. For behavior automation, prefer:
   - `map ... launch ...`
   - `map ... remote_control ...`
   - sessions (`--session`, `startup_session`, `goto_session`)

## Configuration checklist (kitty docs coverage)

When implementing changes, check only relevant sections, but keep these categories in mind:

- Fonts/text rendering (`font_family`, `font_size`, `font_features`, `modify_font`)
- Cursor and scrollback behavior
- Mouse behavior and `mouse_map`
- Performance tuning
- Bell/notifications
- Layouts/windows/tabs (`enabled_layouts`, `layout_action`, window/tab actions)
- Color system/themes (`include current-theme.conf`, dynamic light/dark themes)
- Keyboard mappings (`map`, multi-key mappings, modal maps, conditional maps)
- Clipboard/selection behavior
- Shell integration (`shell_integration` and related flags)
- Sessions (`--session`, `startup_session`, `save_as_session`, `goto_session`)
- Remote control (`allow_remote_control`, `remote_control_password`)
- Open/launch actions (`open-actions.conf`, `launch-actions.conf`, `launch` command)

## Repo implementation pattern (NixOS flake)

When user asks to configure kitty in this repo:

1. Find where to wire module imports (`modules/home/*`, host imports in `flake.nix`).
2. Prefer adding/updating a dedicated home-manager module (for example `modules/home/kitty/default.nix`) instead of scattering settings.
3. Express kitty config as generated text (or Home-Manager kitty options if already used), with clear section comments matching kitty docs.
4. Keep keymaps and theme/font choices separated from core behavior.
5. Run formatting:
   - `nix fmt -- <changed .nix files>`

## Safe patterns and examples

### Include-driven kitty.conf

```conf
# ~/.config/kitty/kitty.conf
include kitty.d/fonts.conf
include kitty.d/colors.conf
include kitty.d/layouts.conf
include kitty.d/keys.conf
```

### Keymap examples

```conf
map kitty_mod+enter new_window_with_cwd
map kitty_mod+t new_tab_with_cwd
map kitty_mod+f7 next_layout
map f1 launch --cwd=current --type=tab
```

### Session quick start

```conf
startup_session ~/.config/kitty/sessions/default.kitty-session
map f7>/ goto_session
map f7>- goto_session -1
```

### Remote control hardening

```conf
allow_remote_control password
remote_control_password "control colors" *-colors
```

## Decision rules

- If user asks for a one-off local tweak: edit kitty conf content only.
- If user asks for persistent machine config in this repo: implement in Nix module(s).
- If user asks for keybinding conflicts: use conditional mappings (`--when-focus-on`) before removing defaults.
- If user asks for "project workspaces": use sessions + `goto_session` mappings.
- If user asks for shell UX improvements: use kitty shell integration features before custom scripting.

## References used

- `.../share/doc/kitty/html/_sources/conf.rst.txt`
- `.../share/doc/kitty/html/_downloads/.../kitty.conf` (fully commented sample)
- `.../share/doc/kitty/html/_sources/mapping.rst.txt`
- `.../share/doc/kitty/html/_sources/layouts.rst.txt`
- `.../share/doc/kitty/html/_sources/launch.rst.txt`
- `.../share/doc/kitty/html/_sources/sessions.rst.txt`
- `.../share/doc/kitty/html/_sources/shell-integration.rst.txt`
- `.../share/doc/kitty/html/_sources/open_actions.rst.txt`
- `.../share/doc/kitty/html/_sources/remote-control.rst.txt`
- `.../share/doc/kitty/html/_sources/kittens/themes.rst.txt`
- `.../share/doc/kitty/html/_sources/kittens/choose-fonts.rst.txt`
