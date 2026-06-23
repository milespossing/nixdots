{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cmake
    gcc
    resterm
    openapi-tui
  ];
}
