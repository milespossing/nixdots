{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    my-nixcats = {
      url = "github:milespossing/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake.url = "github:xremap/nix-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-flake.url = "path:./home-flake";
  };

  outputs =
    {
      flake-utils,
      nixos-hardware,
      nixpkgs,
      home-flake,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        euler = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/core
            ./hosts/euler
            ./modules/secrets
            ./modules/kde
            ./modules/office
            ./modules/syncthing
            ./modules/userland
            ./modules/nixos-tools
            inputs.home-manager.nixosModules.default
            {
              home-manager.users.miles = {
                imports = with home-flake.homeManagerModules; [
                  base
                  navi
                  user-space
                  zen-browser
                ];
                home.stateVersion = "25.11";
              };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
        laplace = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/core
            ./hosts/laplace
            ./modules/userland
            ./modules/syncthing
            ./modules/nixos-tools
            nixos-hardware.nixosModules.framework-13-7040-amd
            ./modules/wm/gnome.nix
            inputs.xremap-flake.nixosModules.default
            inputs.home-manager.nixosModules.default
            {
              home-manager.users.miles = {
                imports = with home-flake.homeManagerModules; [
                  base
                  navi
                  user-space
                  zen-browser
                ];
                home.stateVersion = "25.11";
              };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
        # WSL
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/wsl-work
            ./modules/work
            ./modules/core
            ./modules/ai
            ./modules/wsl
            ./modules/syncthing
            ./modules/nixos-tools
            ./modules/dev
            inputs.home-manager.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.miles = {
                imports = with home-flake.homeManagerModules; [
                  base
                  wsl
                  navi
                  work
                ];
                home.stateVersion = "25.11";
              };
            }
          ];
        };
      };
      devShells = flake-utils.lib.eachDefaultSystemPassThrough (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          ${system}.default = pkgs.mkShell {
            name = "test";
            nativeBuildInputs = with pkgs; [
              nodejs
            ];
          };
        }
      );
    };
}
