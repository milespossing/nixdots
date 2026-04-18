{ pkgs, lib, ... }:
{
  services.udiskie = {
    enable = true;
    tray = "never";
  };

  # udiskie needs graphical-session.target which not all WM launchers activate;
  # override to start on default.target so automount works regardless of session type.
  systemd.user.services.udiskie = {
    Unit = {
      After = lib.mkForce [ "default.target" ];
      PartOf = lib.mkForce [ ];
    };
    Install = {
      WantedBy = lib.mkForce [ "default.target" ];
    };
  };

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
