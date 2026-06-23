{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    zulu
    clojure
    neil
    babashka
  ];
}
