return {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  settings = {
    nixpkgs = {
      expr = 'import <nixpkgs> { }',
    },
    formatting = { command = { 'nixfmt' } },
    options = {
      nixos = {
        expr = '(builtins.getFlake "github:milespossing/nixdots").nixosConfigurations',
      },
      home_manager = '(builtins.getFlake "github:milespossing/nixdots").homeConfigurations',
    },
  },
}
