{ config, pkgs, lib, ... }:
with lib;
let
  posixAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    fzfp = "fzf --preview 'bat --color=always {}' --preview-window '~3'";
  };
  posixInitExtra = ''
    . $HOME/.scripts/fzf-git.sh
    . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
    export PATH="$PATH:/usr/local/bin"
  '';
  cfg = config.posix;
in {
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
      initExtra = posixInitExtra + ''
      . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
      '' + cfg.initExtra + (if config.mp.programs.emacs.useDoom then
        "export PATH=\"$PATH:$HOME/.config/emacs/bin\"\n"
      else "");
    };

    programs.zsh = {
      enable = true;
      shellAliases = posixAliases;
      initExtra = posixInitExtra;
    };

    programs.nushell = {
      enable = true;
    };

    
    home.file.".scripts/fzf-git.sh" = {
      source = ./fzf-git.sh;
    };
  };
}
