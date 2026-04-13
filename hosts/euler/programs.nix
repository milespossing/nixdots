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
