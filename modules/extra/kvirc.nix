{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kvirc
  ];
}
