{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned nixpkgs master for azure-cli fix (nixos/nixpkgs#493712)
    # Remove once nixos-unstable includes azure-cli >= 2.82.0
    nixpkgs-master.url = "github:nixos/nixpkgs/360b78b5de92154bbe2ae12a79eea01b35b2f5ec";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    my-nixcats = {
      url = "path:./nix-cats";
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
  };

  outputs =
    {
      flake-utils,
      nixos-hardware,
      nixpkgs,
      my-nixcats,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nodejs
            sops
          ];
        };
        packages.nvim = my-nixcats.packages.${system}.default;
      }
    )
    // {
      nixosConfigurations =
        let
          overlays = [
            (import ./overlays/zellij-plugins.nix)
            (import ./overlays/azure-cli-fix.nix { nixpkgs-master = inputs.nixpkgs-master; })
          ];
        in
        {
          euler = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              { nixpkgs.overlays = overlays; }
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
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.miles = {
                  imports = [
                    ./modules/home/base
                    ./modules/home/navi
                    ./modules/home/user-space
                    ./modules/home/zen-browser
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
              { nixpkgs.overlays = overlays; }
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
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.miles = {
                  imports = [
                    ./modules/home/base
                    ./modules/home/navi
                    ./modules/home/ai
                    ./modules/home/user-space
                    ./modules/home/zen-browser
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
              { nixpkgs.overlays = overlays; }
              ./hosts/nixos
              ./modules/work
              ./modules/core
              ./modules/wsl
              ./modules/syncthing
              ./modules/nixos-tools
              ./modules/dev
              inputs.home-manager.nixosModules.default
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.miles = {
                  imports = [
                    ./hosts/nixos/home.nix
                    ./modules/home/base
                    ./modules/home/wsl
                    ./modules/home/navi
                    ./modules/home/ai
                    ./modules/home/work
                  ];
                  home.stateVersion = "25.11";
                };
              }
            ];
          };
        };
    };
}
