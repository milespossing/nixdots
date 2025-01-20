{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixos-hardware,
      nixpkgs,
      home-manager,
      sops-nix,
      nixos-wsl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      sharedOptions =
        { lib, ... }:
        {
          options.myConfig = {
            useHyprland = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to use Hyprland.";
            };
          };
          config.userName = lib.mkOption {
            type = lib.types.str;
            default = "miles";
            description = "Username";
          };
        };
    in
    {
      nixosConfigurations = {
        euler = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs sharedOptions; };
          modules = [
            ./hosts/euler/configuration.nix
            ./modules/kde.nix
            inputs.home-manager.nixosModules.default
            sops-nix.nixosModules.sops
          ];
        };
        laplace = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs sharedOptions; };
          modules = [
            ./modules
            ./hosts/laplace/configuration.nix
            ./modules/kde.nix
            inputs.home-manager.nixosModules.default
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs sharedOptions; };
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
      };
      homeConfigurations."mpossing" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./hosts/work-wsl/home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
