{
  description = "Nixos config flake";

  inputs = {
    nixgl.url = "github:nix-community/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixos-hardware,
      nixpkgs,
      sops-nix,
      home-flake,
      my-nixcats,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        (import ./overlays/calibre-8-16.nix)
      ];
      unfreePackages =
        { ... }:
        {
          nixpkgs.config.allowUnfree = true;
        };
    in
    {
      nixosConfigurations = {
        euler = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs.overlays = overlays;
            }
            ./modules/core
            ./hosts/euler/configuration.nix
            ./modules/extra/desktop.nix
            ./modules/extra/3d-printing.nix
            ./modules/extra/secrets.nix
            ./modules/extra/networking.nix
            ./modules/wm/kde.nix
            ./modules/extra/syncthing.nix
            inputs.home-manager.nixosModules.default
            {
              home-manager.users.miles =
                { ... }:
                {
                  imports = [
                    ./home/modules/common.nix
                    ./home/modules/development/all.nix
                    ./home/modules/nixos.nix
                    ./home/modules/user-space.nix
                    ./home/modules/personal.nix
                    ./home/modules/secrets.nix
                  ];
                  home.stateVersion = "23.11"; # Please read the comment before changing.
                };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            sops-nix.nixosModules.sops
          ];
        };
        laplace = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/core
            ./hosts/laplace/configuration.nix
            ./hosts/laplace/hardware-configuration.nix
            ./modules/wm/gnome.nix
            ./modules/extra/networking.nix
            ./modules/extra/zen-browser.nix
            ./modules/extra/syncthing.nix
            inputs.xremap-flake.nixosModules.default
            inputs.home-manager.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.miles =
                { ... }:
                {
                  imports = [
                    ./home/modules/common.nix
                    ./home/modules/development/all.nix
                    ./home/modules/nixos.nix
                    ./home/modules/user-space.nix
                    ./home/modules/personal.nix
                  ];
                  home.stateVersion = "23.11"; # Please read the comment before changing.
                };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };
        # WSL
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = system;
          modules = [
            unfreePackages
            ./modules/extra/wsl.nix
            ./modules/core
            my-nixcats.nixosModules.default
            {
              nixcats-full.enable = true;
            }
            inputs.nixos-wsl.nixosModules.wsl
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
      homeConfigurations.miles = home-flake.lib.mkHome {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        username = "miles";
        homeDirectory = "/home/miles";
      };
      devShells."${system}".default =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            sops
            age
          ];
        };
    };
}
