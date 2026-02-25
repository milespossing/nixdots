{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    extraConfig = ''
      keybinds {
        shared_except "locked" {
          bind "Ctrl k" {
            LaunchOrFocusPlugin "file:${pkgs.zellij-forgot}/bin/zellij_forgot.wasm" {
              "LOAD_ZELLIJ_BINDINGS" "true"
              "lazygit" "alt + g"
              floating true
            }
          }
        }
        normal {
          bind "Alt g" {
            Run "lazygit" {
              in_place true
              close_on_exit true
            };
          }
        }
      }
    '';
    settings = {
      theme = "catppuccin-macchiato";
      default_layout = "compact";
    };
  };
}
