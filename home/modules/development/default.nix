{ pkgs, ... }:
{
  imports = [
    ./all.nix
    ./dotnet.nix
    ./racket.nix
    ./scala.nix
  ];
}
