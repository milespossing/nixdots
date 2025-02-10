{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # wine-staging (version with experimental features)
    wineWowPackages.stagingFull

    # winetricks (all versions)
    winetricks
  ];
}
