{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp
    sqlite
    qmk
    ffmpeg-full
    parallel
    spotify
    freecad-wayland
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
