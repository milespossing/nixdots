{ pkgs, ... }:
{
  imports = [
    ./sway.nix
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
}
