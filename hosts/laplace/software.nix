{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.pi-coding-agent-desktop # desktop pi (common base wrapper)
  ];
  programs.steam = {
    enable = true;
  };
}
