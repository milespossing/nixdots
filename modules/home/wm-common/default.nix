{ pkgs, ... }:
{
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./swayidle.nix
    ./swaylock.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    pamixer
    playerctl
    networkmanagerapplet
    pavucontrol
    libnotify
    wl-clipboard
    grim
    slurp
    swappy
    cliphist
    awww
    jq
  ];

  home.pointerCursor = {
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard+default";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    gtk4.theme = null;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "mocha";
      };
    };
  };
}
