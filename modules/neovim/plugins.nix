{ pkgs }:
with pkgs.vimPlugins;
{
  # Plugins loaded at startup (always on rtp).
  # Keep this minimal — only plugins that must be available
  # before init.lua runs or that cannot be deferred.
  start = [
    lze
    blink-cmp
    which-key-nvim
    vim-startuptime
    lualine-nvim
    alpha-nvim
    nvim-web-devicons
  ];

  # Plugins loaded on demand via lze (packadd).
  # Each entry here is a vim plugin derivation.
  # Lazy-load triggers are defined in lua/plugins/*.lua specs.
  opt = [
    catppuccin-nvim
    nvim-treesitter.withAllGrammars
    fzf-lua
    nfnl
    flash-nvim
    neo-tree-nvim
    nvim-surround
    grug-far-nvim
    nvim-ufo
    trouble-nvim
    nvim-paredit
    nvim-parinfer
    conjure
    mini-nvim
    dial-nvim
  ];
}
