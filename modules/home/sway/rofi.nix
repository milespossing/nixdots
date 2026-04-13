{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    theme =
      let
        inherit (builtins) toString;
      in
      toString ./rofi-theme.rasi;
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " ";
      drun-display-format = "{name}";
    };
  };

  home.packages = with pkgs; [ papirus-icon-theme ];
}
