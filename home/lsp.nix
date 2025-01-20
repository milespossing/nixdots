{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # nix
    nil
    nixfmt-rfc-style
    # Lisps
    clojure-lsp
    # Lua
    lua-language-server
    stylua
    # Node
    nodePackages.vim-language-server
    # Misc.
    typst-lsp
    tree-sitter-grammars.tree-sitter-typst
    yaml-language-server
  ];
}
