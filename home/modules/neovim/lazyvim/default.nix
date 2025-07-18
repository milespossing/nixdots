{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    # Make sure sqlite is available to nvim
    extraWrapperArgs = [
      "--set"
      "LIBSQLITE"
      "${pkgs.sqlite.out}/lib/libsqlite3.so"
    ];

    # Everything the body needs
    extraPackages = with pkgs; [
      curl
      gcc
      sqlite
      # DAP
      vscode-js-debug
      # dotnet
      csharp-ls
      csharpier
      # json
      fixjson
      # Lisps
      clojure-lsp
      cljfmt
      # Lua
      lua-language-server
      stylua
      fennel-ls
      fnlfmt
      # node
      nodejs
      # nix
      nil
      nixfmt-rfc-style
      # Node, JS & TS
      typescript-language-server
      nodePackages.prettier
      eslint_d
      # Rust
      cargo
      rust-analyzer
      rustfmt
      # Misc.
      nginx-language-server
      nodePackages.vim-language-server
      # typst-lsp
      tree-sitter-grammars.tree-sitter-typst
      yaml-language-server
      vscode-langservers-extracted
    ];
  };

  # Distribute dotfiles
  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
