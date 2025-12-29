{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
  ];
}
