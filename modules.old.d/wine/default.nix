{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # wine-staging (version with experimental features)
    wineWow64Packages.stagingFull

    # winetricks (all versions)
    winetricks
  ];
}
