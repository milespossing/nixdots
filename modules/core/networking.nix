{ ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;

  services.resolved.enable = true;
  services.openssh.enable = true;
}
