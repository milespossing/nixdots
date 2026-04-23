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

  # Disable ERTM to fix Xbox controller Bluetooth reconnect loop
  boot.extraModprobeConfig = "options bluetooth disable_ertm=Y";

  # Enable networking
  networking.hostName = "euler"; # Define your hostname.
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

    # Focusrite Scarlett 2i2 Gen 4: ACP fails to populate EnumProfile
    # at boot (race with USB audio init), leaving the device stuck on
    # the "off" profile. Letting ACP auto-select the profile internally
    # bypasses WirePlumber's EnumProfile iteration that hits the empty list.
    wireplumber.extraConfig."51-scarlett-auto-profile" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.vendor.id" = "0x1235";
              "device.product.id" = "0x8219";
            }
          ];
          actions.update-props = {
            "api.acp.auto-profile" = true;
          };
        }
      ];
    };
  };

  # Never sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
