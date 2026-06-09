{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types concatMapStringsSep;

  entryType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Human-readable label shown in the fzf picker.";
      };
      command = mkOption {
        type = types.str;
        description = ''
          The tmux command (and arguments) to execute when this entry is selected.
          Passed verbatim to `tmux` via the shell, so standard tmux quoting rules apply.
        '';
        example = "split-window -h";
      };
    };
  };

  cfg = config.my.tmux.menu;

  entriesText = concatMapStringsSep "\n" (e: "${e.name}\t${e.command}") cfg.entries;

  tmux-menu = pkgs.writeShellScriptBin "tmux-menu" ''
    set -euo pipefail

    entries=$(cat <<'TMUX_MENU_ENTRIES_EOF'
    ${entriesText}
    TMUX_MENU_ENTRIES_EOF
    )

    choice=$(printf '%s\n' "$entries" \
      | ${pkgs.fzf}/bin/fzf \
          --with-nth=1 \
          --delimiter=$'\t' \
          --prompt='tmux ❯ ' \
          --reverse \
          --header='enter=run · esc=cancel') || exit 0

    [ -n "$choice" ] || exit 0
    cmd=''${choice#*$'\t'}
    eval "${pkgs.tmux}/bin/tmux $cmd"
  '';
in
{
  options.my.tmux.menu = {
    entries = mkOption {
      type = types.listOf entryType;
      default = [ ];
      description = ''
        Entries shown in the tmux fzf menu (bound to `prefix + Space`).
        Each entry has a `name` (shown in the picker) and a `command`
        (a tmux command run when the entry is selected).
      '';
      example = lib.literalExpression ''
        [
          { name = "session: switch"; command = "choose-tree -Zs"; }
          { name = "pane: zoom toggle"; command = "resize-pane -Z"; }
        ]
      '';
    };
  };

  config = {
    my.tmux.menu.entries = lib.mkBefore [
      {
        name = "session: switch";
        command = "choose-tree -Zs";
      }
      {
        name = "session: new";
        command = "new-session";
      }
      {
        name = "session: rename";
        command = ''command-prompt -I "#S" "rename-session -- '%%'"'';
      }
      {
        name = "window: new";
        command = "new-window";
      }
      {
        name = "window: rename";
        command = ''command-prompt -I "#W" "rename-window -- '%%'"'';
      }
      {
        name = "window: kill";
        command = "kill-window";
      }
      {
        name = "pane: zoom toggle";
        command = "resize-pane -Z";
      }
      {
        name = "pane: kill";
        command = "kill-pane";
      }
      {
        name = "layout: tiled";
        command = "select-layout tiled";
      }
      {
        name = "layout: main-vertical";
        command = "select-layout main-vertical";
      }
      {
        name = "layout: even-horizontal";
        command = "select-layout even-horizontal";
      }
      {
        name = "clock";
        command = "clock-mode";
      }
    ];

    home.packages = [
      pkgs.tmux
      tmux-menu
    ];
  };
}
