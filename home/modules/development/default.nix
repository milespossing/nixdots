{ pkgs, ... }:
{
  imports = [
    ./all.nix
    ./clojure.nix
    ./dotnet.nix
    ./racket.nix
    ./scala.nix
  ];
}
