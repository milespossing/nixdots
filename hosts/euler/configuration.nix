# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  ...
}:
{
  # misc.
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
    systemd-boot.enable = true;
  };

  # Enable networking
  networking.hostName = "euler"; # Define your hostname.
  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  networking.wireguard.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8080 ];
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.samba = {
    enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Never sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
