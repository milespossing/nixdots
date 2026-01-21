{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    zulu
    clojure
    babashka
  ];
}
