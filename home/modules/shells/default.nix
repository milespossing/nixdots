{ pkgs, ... }:
let
  posixAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
  };
  posixInitExtra = ''
    . $HOME/.scripts/fzf-git.sh
    . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
    export PATH="$PATH:/usr/local/bin"
  '';
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = posixAliases;
    initExtra = posixInitExtra + ''
    . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
    '';
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
}
