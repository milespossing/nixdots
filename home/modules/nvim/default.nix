{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.neovim.enable {
    programs.neovim.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    programs.neovim.extraPackages = with pkgs; [
      chafa
      gcc
      # dotnet
      csharp-ls
      csharpier
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
      cargo
      rust-analyzer
      rustfmt
      # Misc.
      nginx-language-server
      nodePackages.vim-language-server
      typst-lsp
      tree-sitter-grammars.tree-sitter-typst
      yaml-language-server
    ];

    home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
}
