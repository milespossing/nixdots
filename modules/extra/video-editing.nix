{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    davinci-resolve
  ];

  programs.obs-studio = {
    enable = true;
  };
}
