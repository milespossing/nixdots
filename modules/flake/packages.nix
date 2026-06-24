{ inputs, ... }:
{
  # nvim (a callPackage, not a wrapper) plus the raw version-pinned upstream pi.
  # The wrapped tools (kitty, tmux, yazi, hunk, worktrunk, pi-coding-agent-*, …)
  # are exposed automatically as `packages.<system>.<name>` by the flake.wrappers
  # registry in modules/flake/wrappers.nix — e.g. `nix run .#kitty`,
  # `nix build .#pi-coding-agent-wsl`.
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ../../overlays/kulala-nvim.nix)
          (import ../../overlays/pi-coding-agent.nix)
          (final: _prev: {
            nvim = final.callPackage ../../pkgs/neovim {
              inherit (inputs) fennel-ls-nvim-docs;
            };
          })
        ];
      };
      app = drv: bin: {
        type = "app";
        program = "${drv}/bin/${bin}";
      };
    in
    {
      packages = {
        inherit (pkgs) nvim;
        pi-upstream = pkgs.pi-coding-agent;
      };

      apps = {
        nvim = app pkgs.nvim "nvim";
      };
    };
}
