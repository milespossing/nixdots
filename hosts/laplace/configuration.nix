{
  pkgs,
  ...
}:
{
  networking.hostName = "laplace"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Laptop power management — UPower drives noctalia's Battery widget.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # misc.
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.xremap = {
    enable = true;
    config.modmap = [
      {
        name = "Global";
        remap = {
          "CapsLock" = "Esc";
        };
      }
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  my.flakePath = "/home/miles/.config/nixos";

  users.users.mpossing = {
    isNormalUser = true;
    description = "Miles Possing";
    extraGroups = [
      "networkmanager"
      "wheel"
      "storage"
    ];
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
