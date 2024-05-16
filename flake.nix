{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, nixos-wsl, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      sharedOptions = { lib, ... }: {
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
            inputs.home-manager.nixosModules.default
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
          ./home/wsl.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      darwinConfigurations."macbook" =
        let
          system = "aarch64-darwin";
          # pkgs-unstable = import nixpkgs-unstable { inherit system; };
        in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs sharedOptions;
          };
          modules = [
            ./hosts/macbook/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
    };
}
