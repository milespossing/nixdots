{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    clojure-lsp
  ];
}
