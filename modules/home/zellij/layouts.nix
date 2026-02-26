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
      if [ -n "$ZELLIJ_SESSION_NAME" ]; then
        zellij action go-to-tab-name "Editor"
      fi
    else
      nvim "$@"
    fi
  '';

  yazi-ide = pkgs.writeShellScriptBin "yazi-ide" ''
    export EDITOR="${nvim-remote-open}/bin/nvim-remote-open"
    exec yazi "$@"
  '';
in
{
  home.packages = [
    nvim-ide
    nvim-remote-open
    yazi-ide
  ];

  programs.zellij.layouts = {
    ide = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          children
          pane size=2 borderless=true {
            plugin location="zellij:status-bar"
          }
        }
        tab name="Editor" focus=true {
          pane split_direction="horizontal" {
            pane command="${nvim-ide}/bin/nvim-ide" size="80%"
            pane size="20%"
          }
        }
        tab name="Git" {
          pane command="lazygit"
        }
        tab name="Files" {
          pane command="${yazi-ide}/bin/yazi-ide"
        }
        tab name="Shell" {
          pane
        }
      }
    '';

    copilot = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          children
          pane size=2 borderless=true {
            plugin location="zellij:status-bar"
          }
        }
        tab name="Copilot" focus=true {
          pane split_direction="vertical" {
            pane command="copilot" size="60%"
            pane command="nvim" size="40%"
          }
        }
        tab name="Editor" {
          pane command="nvim"
        }
        tab name="Git" {
          pane command="lazygit"
        }
        tab name="Shell" {
          pane
        }
      }
    '';

    explore = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          children
          pane size=2 borderless=true {
            plugin location="zellij:status-bar"
          }
        }
        tab name="Files" focus=true {
          pane split_direction="vertical" {
            pane command="yazi" size="40%"
            pane command="nvim" size="60%"
          }
        }
        tab name="Search" {
          pane
        }
        tab name="Git" {
          pane command="lazygit"
        }
      }
    '';
  };
}
