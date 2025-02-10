{ ... }:
{
  imports = [
    ./fonts.nix
    ./gpg.nix
    ./locale.nix
    ./networking.nix
    ./programs.nix
    ./user.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # misc.
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };
}
