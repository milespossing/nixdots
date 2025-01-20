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
    };

    programs.nushell = {
      enable = true;
    };

    home.file.".scripts/fzf-git.sh" = {
      source = ./fzf-git.sh;
    };
  };
}
