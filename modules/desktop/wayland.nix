{ config, ... }:
{
  # Wayland layer: imports desktop-core, adds wayland session tooling + greeter.
  flake.modules.nixos.desktop-wayland = {
    imports = [ config.flake.modules.nixos.desktop-core ];

    environment.pathsToLink = [ "/share/wayland-sessions" ];
    services.geoclue2.enable = true;
    services.accounts-daemon.enable = true;
  };

  flake.modules.homeManager.desktop-wayland =
    { pkgs, ... }:
    {
      imports = [ config.flake.modules.homeManager.desktop-core ];
      home.packages = with pkgs; [
        wl-clipboard
        grim
        slurp
        swappy
        cliphist
      ];
    };
}
