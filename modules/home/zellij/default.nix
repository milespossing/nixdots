{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ ./layouts.nix ];

  options.my.zellij.autoStart = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to auto-start zellij in new shell sessions.";
  };

  config = {
    programs.zellij = {
      enable = true;
      enableBashIntegration = config.my.zellij.autoStart;
      enableFishIntegration = config.my.zellij.autoStart;
      extraConfig = ''
        plugins {
          autolock location="file:${pkgs.zellij-autolock}/bin/zellij-autolock.wasm" {
            is_enabled true
            triggers "nvim|vim|git|fzf|zoxide|atuin|yazi"
            reaction_seconds "0.3"
            print_to_log false
          }
        }
        load_plugins {
          autolock
        }
        keybinds {
          // autolock
          shared_except "locked" {
            bind "Ctrl h" { MoveFocusOrTab "Left"; }
            bind "Ctrl l" { MoveFocusOrTab "Right"; }
            bind "Ctrl j" { MoveFocus "Down"; }
            bind "Ctrl k" { MoveFocus "Up"; }
            bind "Alt z" {
              MessagePlugin "autolock" { payload "disable"; };
              SwitchToMode "Locked";
            }
          }
          locked {
            bind "Alt z" {
              MessagePlugin "autolock" { payload "disable"; };
              SwitchToMode "Normal";
            }
          }
          shared {
            bind "Alt Shift z" {
              MessagePlugin "autolock" { payload "enable"; };
            }
          }
          normal {
            bind "Alt g" {
              Run "lazygit" {
                name "lazygit"
                floating true
                height "98%"
                width "96%"
                x "2%"
                y "4%"
                close_on_exit true
              };
            }
            bind "Alt c" {
              Run "copilot" {
                name "copilot"
                floating true
                height "98%"
                width "96%"
                x "2%"
                y "4%"
                close_on_exit true
                in_place false
              };
            }
            bind "Alt Shift c" {
              Run "copilot" "--resume" {
                name "copilot-resume"
                floating true
                height "98%"
                width "96%"
                x "2%"
                y "4%"
                close_on_exit true
                in_place false
              };
            }
            // autolock
            bind "Enter" {
              WriteChars "\u{000D}";
              MessagePlugin "autolock" {};
            }
          }
        }
      '';
      settings = {
        show_startup_tips = false;
        theme = "catppuccin-macchiato";
      };
    };
  };
}
