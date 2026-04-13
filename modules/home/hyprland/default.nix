{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    pamixer
    playerctl
    networkmanagerapplet
    pavucontrol
    libnotify
    hyprpicker
    wl-clipboard
    grim
    slurp
    swappy
    cliphist
    awww
  ];
}
