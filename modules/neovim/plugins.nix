{ pkgs }:
with pkgs.vimPlugins;
let
  treesitter = nvim-treesitter.withPlugins (
    plugins: with plugins; [
      nix
      lua
      fennel
      c_sharp
      javascript
      typescript
      clojure
      regex
      bash
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
    blink-cmp
    nui-nvim
    nvim-notify
    nvim-web-devicons
    vim-startuptime
    which-key-nvim
  ];

  # Plugins loaded on demand via lze (packadd).
  # Each entry here is a vim plugin derivation.
  # Lazy-load triggers are defined in lua/plugins/*.lua specs.
  opt = [
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
    lualine-nvim
    mini-nvim
    neo-tree-nvim
    noice-nvim
    nvim-lint
    nvim-surround
    nvim-ufo
    nvim-paredit
    nvim-parinfer
    todo-comments-nvim
    treesitter
    trouble-nvim
    zellij-nav-nvim
  ];
}
