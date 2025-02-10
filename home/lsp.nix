{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # nix
    nil
    nixfmt-rfc-style
    # Lisps
    clojure-lsp
    cljfmt
    # Lua
    lua-language-server
    stylua
    fennel-ls
    fnlfmt
    # Node & TS
    typescript-language-server
    nodePackages.prettier
    # Rust
    rust-analyzer
    rustfmt
    # Misc.
    nginx-language-server
    nodePackages.vim-language-server
    typst-lsp
    tree-sitter-grammars.tree-sitter-typst
    yaml-language-server
  ];
}
