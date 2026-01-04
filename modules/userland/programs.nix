{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    logseq
    discord
    spotify
  ];
}
