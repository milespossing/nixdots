{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned nixpkgs master for azure-cli fix (nixos/nixpkgs#493712)
    # Remove once nixos-unstable includes azure-cli >= 2.82.0
    nixpkgs-master.url = "github:nixos/nixpkgs/360b78b5de92154bbe2ae12a79eea01b35b2f5ec";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake.url = "github:xremap/nix-flake";
    charmbracelet-nur = {
      url = "github:charmbracelet/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
    # Neovim nightly for nvim — do NOT follow nixpkgs (tree-sitter hash mismatch)
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # fennel-ls docsets for Neovim API completions/hover
    fennel-ls-nvim-docs = {
      url = "git+https://git.sr.ht/~micampe/fennel-ls-nvim-docs";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixos-hardware,
      nixpkgs,
      nur,
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
            bashInteractive
            nodejs
            sops
          ];
        };
        packages.nvim = (import nixpkgs { inherit system; }).callPackage ./modules/neovim {
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${system}.neovim;
          fennel-ls-nvim-docs = inputs.fennel-ls-nvim-docs;
        };
        apps.nvim = {
          type = "app";
          program = "${self.packages.${system}.nvim}/bin/nvim";
        };
      }
    )
    // {
      nixosConfigurations =
        let
          overlays = [
            (import ./overlays/zellij-plugins.nix)
            (import ./overlays/azure-cli-fix.nix { nixpkgs-master = inputs.nixpkgs-master; })
            (import ./overlays/agent-skills)
            (import ./overlays/agent-mcps)
            inputs.nix-openclaw.overlays.default
            (final: prev: {
              nvim = final.symlinkJoin {
                name = "nvim";
                paths = [
                  (final.callPackage ./modules/neovim {
                    neovim-unwrapped =
                      inputs.neovim-nightly-overlay.packages.${final.stdenv.hostPlatform.system}.neovim;
                    fennel-ls-nvim-docs = inputs.fennel-ls-nvim-docs;
                  })
                ];
              };
            })
            nur.overlays.default
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
              ./modules/openclaw-node
              {
                my.openclaw-node = {
                  enable = true;
                  displayName = "euler";
                  tls = true;
                };
              }
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
                home-manager.users.miles =
                  { pkgs, ... }:
                  {
                    imports = [
                      ./modules/home/base
                      ./modules/home/navi
                      ./modules/home/ai
                      ./modules/home/user-space
                      ./modules/home/zen-browser
                    ];
                    my.ai.aider.enable = true;
                    my.ai.opencode.enable = true;
                    my.ai.copilot-cli.enable = true;
                    my.ai.skills.discover-plugins = pkgs.agenticSkills.discover-plugins;
                    my.ai.skills.skillsmp-search = pkgs.agenticSkills.skillsmp-search;
                    my.ai.skills.install-skill = pkgs.agenticSkills.install-skill;
                    my.ai.skills.az-cli = pkgs.agenticSkills.az-cli;
                    home.stateVersion = "25.11";
                  };
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          };
          # WSL
          nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
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
                home-manager.users.miles =
                  { pkgs, ... }:
                  {
                    imports = [
                      ./hosts/nixos/home.nix
                      ./modules/home/base
                      ./modules/home/wsl
                      ./modules/home/navi
                      ./modules/home/ai
                      ./modules/home/work
                    ];
                    my.ai.aider.enable = true;
                    my.ai.opencode.enable = true;
                    my.ai.copilot-cli.enable = true;
                    my.ai.mcp.servers.workiq = pkgs.agenticMcps.workiq;
                    my.ai.skills.discover-plugins = pkgs.agenticSkills.discover-plugins;
                    my.ai.skills.skillsmp-search = pkgs.agenticSkills.skillsmp-search;
                    my.ai.skills.install-skill = pkgs.agenticSkills.install-skill;
                    my.ai.skills.az-cli = pkgs.agenticSkills.az-cli;
                    home.stateVersion = "25.11";
                  };
              }
            ];
          };
        };
    };
}
