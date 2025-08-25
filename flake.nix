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
        inherit system;
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
            ./modules/extra/calibre.nix
            ./modules/extra/secrets.nix
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
        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = system;
          modules = [
            inputs.nixos-wsl.nixosModules.wsl
            {
              system.stateVersion = "25.05";
              wsl.enable = true;
              wsl.defaultUser = "miles";
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            }
            inputs.home-manager.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.miles =
                { ... }:
                {
                  imports = [
                    ./home/modules/common.nix
                    ./home/modules/development/all.nix
                    ./home/modules/work.nix
                    ./home/modules/wsl.nix
                    ./home/modules/secrets.nix
                  ];
                  home.stateVersion = "23.11"; # Please read the comment before changing.
                };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
      homeConfigurations."mpossing" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs; };
        inherit pkgs;
        modules = [
          inputs.my-nixcats.homeModules.default
          sops-nix.homeManagerModules.sops
          ./home/hosts/work-wsl.nix
        ];
      };
      devShells."${system}".default = pkgs.mkShell {
        buildInputs = with pkgs; [
          sops
          age
        ];
      };
    };
}
