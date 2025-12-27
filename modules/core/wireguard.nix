{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
  networking.wireguard = {
    enable = true;
  };
}
