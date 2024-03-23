{ pkgs, ... }:
{
  imports = [
    ./alacritty-nord.nix
  ];
  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "discord"
  #     "spotify"
  #   ];

  home.packages = with pkgs; [
    # firefox
    # thunderbird
    # discord
    racket
    emacs29
    # spotify
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  fonts.fontconfig.enable = true;

  home.file.".config/emacs" = {
    source = ./dots/emacs;
    recursive = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 13;
        normal.family = "FiraCode Nerd Font Mono";
      };
      window = {
        opacity = 0.9;
        blur = true;
      };
    };
  };
}
