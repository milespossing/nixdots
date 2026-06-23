{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    let
      nvim-ide = pkgs.writeShellScriptBin "nvim-ide" ''
        SOCKET="/tmp/nvim-''${ZELLIJ_SESSION_NAME:-default}"
        exec nvim --listen "$SOCKET" "$@"
      '';
      nvim-remote-open = pkgs.writeShellScriptBin "nvim-remote-open" ''
        SOCKET="/tmp/nvim-''${ZELLIJ_SESSION_NAME:-default}"
        if [ -S "$SOCKET" ]; then
          nvim --server "$SOCKET" --remote "$@"
          [ -n "$ZELLIJ_SESSION_NAME" ] && zellij action go-to-tab-name "Editor"
        else
          nvim "$@"
        fi
      '';
      yazi-ide = pkgs.writeShellScriptBin "yazi-ide" ''
        export EDITOR="${nvim-remote-open}/bin/nvim-remote-open"
        exec yazi "$@"
      '';
      opencode-ide = pkgs.writeShellScriptBin "opencode-ide" ''
        export EDITOR="${nvim-remote-open}/bin/nvim-remote-open"
        exec opencode "$@"
      '';
      tabTemplate = ''
        default_tab_template {
          pane size=1 borderless=true { plugin location="zellij:tab-bar" }
          children
          pane size=2 borderless=true { plugin location="zellij:status-bar" }
        }
      '';
    in
    {
      home.packages = [
        nvim-ide
        nvim-remote-open
        yazi-ide
        opencode-ide
      ];

      programs.zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        settings = {
          show_startup_tips = false;
          theme = "catppuccin-macchiato";
        };
        extraConfig = ''
          plugins {
            autolock location="file:${pkgs.zellij-autolock}/bin/zellij-autolock.wasm" {
              is_enabled true
              triggers "nvim|vim|git|fzf|zoxide|atuin|yazi"
              reaction_seconds "0.3"
              print_to_log false
            }
          }
          load_plugins { autolock }
          keybinds {
            shared_except "locked" {
              bind "Ctrl h" { MoveFocusOrTab "Left"; }
              bind "Ctrl l" { MoveFocusOrTab "Right"; }
              bind "Ctrl j" { MoveFocus "Down"; }
              bind "Ctrl k" { MoveFocus "Up"; }
              bind "Alt z" { MessagePlugin "autolock" { payload "disable"; }; SwitchToMode "Locked"; }
            }
            locked {
              bind "Alt z" { MessagePlugin "autolock" { payload "disable"; }; SwitchToMode "Normal"; }
            }
            shared {
              bind "Alt Shift z" { MessagePlugin "autolock" { payload "enable"; }; }
            }
            normal {
              bind "Alt g" { Run "lazygit" { name "lazygit"; floating true; height "98%"; width "96%"; x "2%"; y "4%"; close_on_exit true; }; }
              bind "Enter" { WriteChars "\u{000D}"; MessagePlugin "autolock" {}; }
            }
          }
        '';
        layouts = {
          ide = ''
            layout {
              ${tabTemplate}
              tab name="Editor" focus=true {
                pane split_direction="horizontal" {
                  pane command="${nvim-ide}/bin/nvim-ide" size="80%"
                  pane size="20%"
                }
              }
              tab name="Git" { pane command="lazygit" }
              tab name="Files" { pane command="${yazi-ide}/bin/yazi-ide" }
              tab name="Shell" { pane }
            }
          '';
          opencode = ''
            layout {
              ${tabTemplate}
              tab name="OpenCode" focus=true {
                pane split_direction="vertical" {
                  pane command="${opencode-ide}/bin/opencode-ide" size="60%"
                  pane command="${nvim-ide}/bin/nvim-ide" size="40%"
                }
              }
              tab name="Git" { pane command="lazygit" }
              tab name="Files" { pane command="${yazi-ide}/bin/yazi-ide" }
              tab name="Shell" { pane }
            }
          '';
        };
      };
    };
}
