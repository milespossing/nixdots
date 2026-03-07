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
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.obs-studio = {
    enable = true;
  };
}
