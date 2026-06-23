{ inputs, ... }:
{
  # Expose the wrapped tools as flake outputs:
  #   nix run .#pi-desktop / .#pi-wsl / .#nvim / .#kitty
  perSystem =
    { system, ... }:
    let
      wlib = inputs.nix-wrapper-modules.lib;
      wrappers = import ../../wrappers { inherit (inputs.nixpkgs) lib; };
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ../../overlays/kulala-nvim.nix)
          (import ../../overlays/pi-coding-agent.nix)
          (import ../../overlays/pi-extensions)
          (wrappers.overlay wlib)
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
        inherit (pkgs) nvim kitty;
        pi-upstream = pkgs.pi-coding-agent-upstream;
        pi-base = pkgs.pi-coding-agent-base;
        pi-desktop = pkgs.pi-coding-agent-desktop;
        pi-wsl = pkgs.pi-coding-agent-wsl;
      };

      apps = {
        pi-desktop = app pkgs.pi-coding-agent-desktop "pi";
        pi-wsl = app pkgs.pi-coding-agent-wsl "pi";
        nvim = app pkgs.nvim "nvim";
        kitty = app pkgs.kitty "kitty";
      };
    };
}
