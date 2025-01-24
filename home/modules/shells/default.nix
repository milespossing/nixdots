{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  posixAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    fzfp = "fzf --preview 'bat --color=always {}' --preview-window '~3'";
  };
  fzfGitInit = ''
    . $HOME/.scripts/fzf-git.sh
  '';
  posixInitExtra = ''
    export PATH="$PATH:/usr/local/bin"
  '';
  cfg = config.posix;
in
{
  options.posix = {
    initExtra = mkOption {
      type = types.str;
      default = "";
      description = "Extra init for posix shells";
    };
  };
  config = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = posixAliases;
      initExtra = posixInitExtra + fzfGitInit + cfg.initExtra;
    };

    programs.zsh = {
      enable = true;
      shellAliases = posixAliases;
      initExtra = posixInitExtra + cfg.initExtra;
    };

    programs.fish = {
      enable = true;
      generateCompletions = true;
      shellAliases = posixAliases;
      shellInit = posixInitExtra + cfg.initExtra;
      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      interactiveShellInit = ''
        set -g fish_key_bindings fish_vi_key_bindings
        bind \x20wj 'zellij-move down'
        bind \x20wk 'zellij-move up'
        bind \x20wh 'zellij-move left'
        bind \x20wl 'zellij-move right'
        bind \x20t 'zellij-new-tab' 
        bind \x20p 'zellij-new-pane'
      '';

      functions = {
        zellij-move = {
          body = "zellij action move-focus-or-tab $dir";
          argumentNames = "dir";
          description = "Move zellij focus or tab in a given direction";
        };
        zellij-new-tab = {
          body = "zellij action new-tab";
          description = "Create a new tab";
        };
        zellij-new-pane = {
          body = "zellij action new-pane";
          description = "Create a new pane";
        };
        # TODO: Make a nice automatically vi:normal prompt
      };
    };

    programs.nushell = {
      enable = true;
    };

    home.file.".scripts/fzf-git.sh" = {
      source = ./fzf-git.sh;
    };
  };
}
