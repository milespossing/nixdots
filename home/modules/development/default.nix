{ pkgs, ... }:
{
  imports = [
    ./all.nix
    ./dotnet.nix
    ./scala.nix
  ];
}
