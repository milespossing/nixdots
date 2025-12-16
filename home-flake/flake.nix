{
  description = "My nixos home config as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      mkHome =
        {
          system,
          username,
          homeDirectory,
          pkgs ? null,
          modules ? [ ],
        }:
        let
          pkgs' = if pkgs != null then pkgs else import nixpkgs { inherit system; };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs';
          extraSpecialArgs = { inherit username homeDirectory; };
          modules = [
            (
              { ... }:
              {
                home.username = username;
                home.homeDirectory = homeDirectory;
                home.stateVersion = "25.11";
              }
            )
            self.homeManagerModules.base
          ]
          ++ modules;
        };

    in
    {
      homeManagerModules = {
        base = import ./modules/base;
        wsl = import ./modules/wsl;
        navi = import ./modules/navi;
        work = import ./modules/work;
      };

      lib.mkHome = mkHome;
    };
}
