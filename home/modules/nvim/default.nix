{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvimBinary = "${config.programs.neovim.finalPackage}/bin/nvim";
  openaiKeyPath = config.sops.secrets.openai_api_key.path;

  wrappedNvim = pkgs.writeShellScriptBin "nvim" ''
    export OPENAI_API_KEY=$(< ${openaiKeyPath})
    exec ${nvimBinary} "$@"
  '';
in
{
  config = lib.mkIf config.programs.neovim.enable {
    programs.neovim = {
      # Make sure sqlite is available to nvim
      extraWrapperArgs = [
        "--set"
        "LIBSQLITE"
        "${pkgs.sqlite.out}/lib/libsqlite3.so"
      ];

      # Everything the body needs
      extraPackages = with pkgs; [
        chafa
        gcc
        sqlite
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

    home.packages = [
      wrappedNvim
    ];
  };
}
