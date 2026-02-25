{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.sops-nix.nixosModules.sops
  ];

  wsl = {
    enable = true;
    defaultUser = config.my.username;
  };

  # Secret Service provider for secure token storage (gh, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  environment.systemPackages = [ pkgs.libsecret ];
}
