{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    clojure-lsp
    lua-language-server
    nodePackages.vim-language-server
    yaml-language-server
  ];
}
