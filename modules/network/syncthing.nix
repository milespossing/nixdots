{ config, ... }:
{
  flake.modules.nixos.syncthing = {
    services.syncthing = {
      enable = true;
      group = "users";
      user = config.username;
      configDir = "/home/${config.username}/.config/syncthing";
    };
  };
}
