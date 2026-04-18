{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    thunderbird
    vlc
    gimp
    sqlite
    qmk
    ffmpeg-full
    parallel
    orca-slicer
    # freecad-wayland
    bambu-studio
    calibre
    kvirc
    mangohud
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    package = pkgs.steam.override {
      # Steam bundles a broken NAS audio library (libaudio.so) that segfaults on
      # modern PipeWire systems. Hide it inside the sandbox with an empty file so
      # Steam's integrity checker can't re-download it after deletion.
      extraBwrapArgs = [
        "--ro-bind-try"
        "/dev/null"
        "$HOME/.local/share/Steam/ubuntu12_32/libaudio.so"
      ];
    };
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.gamemode.enable = true;
  programs.obs-studio = {
    enable = true;
  };
}
