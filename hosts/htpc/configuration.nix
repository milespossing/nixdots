# HTPC — couch-friendly media center + Jellyfin server
# Steam Big Picture for gaming, Jellyfin for serving media
{
  pkgs,
  ...
}:
{
  # --- Boot & Hardware ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "htpc";
  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  time.timeZone = "America/Chicago";

  # --- GPU / Graphics ---
  # Enable OpenGL + Vulkan (needed for Steam + Jellyfin hw transcoding)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam 32-bit games
  };

  # Uncomment the right GPU section:
  # --- NVIDIA ---
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  # services.xserver.videoDrivers = [ "nvidia" ];

  # --- AMD ---
  # boot.initrd.kernelModules = [ "amdgpu" ];
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # --- Intel ---
  # hardware.graphics.extraPackages = with pkgs; [
  #   intel-media-driver  # VAAPI for newer Intel
  #   intel-vaapi-driver  # VAAPI for older Intel
  #   intel-compute-runtime  # OpenCL
  # ];

  # --- Audio ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Firewall ---
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8096  # Jellyfin HTTP
      8920  # Jellyfin HTTPS
    ];
    allowedUDPPorts = [
      1900  # Jellyfin DLNA discovery
      7359  # Jellyfin client discovery
    ];
  };

  # --- Never sleep (always-on server) ---
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "25.11";
}
