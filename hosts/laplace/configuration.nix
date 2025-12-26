{
  pkgs,
  ...
}:

{
  networking.hostName = "laplace"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Chicago";

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

  users.users.mpossing = {
    isNormalUser = true;
    description = "Miles Possing";
    extraGroups = [
      "networkmanager"
      "wheel"
      "storage"
    ];
  };

  environment.systemPackages = with pkgs; [
    spotify
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
