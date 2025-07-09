{
  description = "Nixos config flake";

  inputs = {
    nixgl.url = "github:nix-community/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    velovim = {
      url = "github:milespossing/nixvim";
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
      nixos-hardware,
      nixpkgs,
      home-manager,
      sops-nix,
      nixgl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
        overlays = [ nixgl.overlay ];
      };
    in
    {
      nixosConfigurations = {
        euler = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/core
            ./hosts/euler/configuration.nix
            ./modules/extra/zen-browser.nix
            ./modules/extra/secrets.nix
            ./modules/wm/kde.nix
            ./modules/extra/syncthing.nix
            inputs.home-manager.nixosModules.default
            {
              home-manager.users.miles =
                { inputs, ... }:
                {
                  imports = [
                    inputs.velovim.homeModules.${system}.default
                    ./home/hosts/euler.nix
                  ];
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
            ./modules/extra/zen-browser.nix
            ./modules/extra/syncthing.nix
            ./modules/extra/virtualization.nix
            inputs.xremap-flake.nixosModules.default
            inputs.home-manager.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.miles =
                { inputs, ... }:
                {
                  imports = [
                    inputs.velovim.homeModules.${system}.default
                    ./home/hosts/laplace.nix
                  ];
                };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };
      };
      homeConfigurations."mpossing" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs; };
        inherit pkgs;
        modules = [
          sops-nix.homeManagerModules.sops
          ./hosts/work-wsl/home.nix
        ];
      };
    };
}
