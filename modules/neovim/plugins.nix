{ pkgs }:
with pkgs.vimPlugins;
let
  treesitter-kulala-http-grammar = pkgs.tree-sitter.buildGrammar {
    language = "kulala_http";
    version = "5.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "mistweaverco";
      repo = "kulala.nvim";
      rev = "902fc21e8a3fee7ccace37784879327baa6d1ece";
      hash = "sha256-whQpwZMEvD62lgCrnNryrEvfSwLJJ+IqVCywTq78Vf8=";
    };
    location = "lua/tree-sitter";
  };

  treesitter-org-grammar = pkgs.tree-sitter.buildGrammar {
    language = "org";
    version = "2.0.3";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-orgmode";
      repo = "tree-sitter-org";
      rev = "2.0.3";
      hash = "sha256-Ok4BlEshQSAxxIdqPWgYx82ksqm6XJ5G9oXpD94Oozg=";
    };
  };

  treesitter = nvim-treesitter.withPlugins (
    plugins:
    with plugins;
    [
      nix
      lua
      fennel
      c_sharp
      javascript
      typescript
      tsx
      clojure
      regex
      bash
    ]
    ++ [
      treesitter-kulala-http-grammar
      treesitter-org-grammar
    ]
  );
in
{
  # Plugins loaded at startup (always on rtp).
  # Keep this minimal — only plugins that must be available
  # before init.lua runs or that cannot be deferred.
  start = [
    lze

    alpha-nvim
    snacks-nvim
    nui-nvim
    nvim-notify
    nvim-web-devicons
    vim-startuptime
    which-key-nvim

    # Treesitter parsers must be on the rtp at startup so that
    # neotest's headless subprocess can find them.
    treesitter
  ];

  # Plugins loaded on demand via lze (packadd).
  # Each entry here is a vim plugin derivation.
  # Lazy-load triggers are defined in lua/plugins/*.lua specs.
  opt = [
    blink-cmp
    catppuccin-nvim
    comment-nvim
    conform-nvim
    conjure
    dial-nvim
    edgy-nvim
    flash-nvim
    fzf-lua
    gitsigns-nvim
    grug-far-nvim
    indent-blankline-nvim
    kulala-nvim
    lualine-nvim
    mini-nvim
    neo-tree-nvim
    noice-nvim
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-lint
    pkgs.vimPlugins.orgmode
    nvim-surround
    nvim-ufo
    nvim-paredit
    nvim-parinfer
    neotest
    neotest-vitest
    FixCursorHold-nvim
    todo-comments-nvim
    trouble-nvim
    zellij-nav-nvim
  ];
}
