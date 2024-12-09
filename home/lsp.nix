{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    clojure-lsp
    lua-language-server
    nodePackages.vim-language-server
    typst-lsp
    tree-sitter-grammars.tree-sitter-typst
    yaml-language-server
  ];
}
