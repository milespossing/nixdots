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
    fennel-ls
    fnlfmt
    # Node & TS
    typescript-language-server
    # Misc.
    nginx-language-server
    nodePackages.vim-language-server
    typst-lsp
    tree-sitter-grammars.tree-sitter-typst
    yaml-language-server
  ];
}
