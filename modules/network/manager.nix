{
  flake.modules.nixos.base = {
    networking.networkmanager.enable = true;
    services.resolved.enable = true;
  };
}
