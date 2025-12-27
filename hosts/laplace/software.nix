{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    spotify
  ];
  programs.steam = {
    enable = true;
  };
}
