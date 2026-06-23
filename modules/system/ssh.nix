{ config, ... }:
{
  flake.modules.nixos.base = {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings.AllowUsers = [ config.username ];
    };
  };
}
