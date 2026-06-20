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
    sops-nix.url = "github:Mic92/sops-nix";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
    # fennel-ls docsets for Neovim API completions/hover
    fennel-ls-nvim-docs = {
      url = "git+https://git.sr.ht/~micampe/fennel-ls-nvim-docs";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk-flake = {
      url = "github:max-sixty/worktrunk";
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
        wlib = inputs.nix-wrapper-modules.lib;
        wrappers = import ./wrappers { inherit (nixpkgs) lib; };
        pkgs = import nixpkgs {
          inherit system;
          # Just the overlays the per-system outputs need. The richer
          # set used by `nixosConfigurations` lives in its own `let`
          # binding below and pulls in WM/host-specific stuff that
          # `nix build .#<pkg>` consumers don't care about.
          overlays = [
            (import ./overlays/pi-coding-agent.nix)
            (import ./overlays/pi-extensions)
            (wrappers.overlay wlib)
          ];
        };
      in
      {
        formatter = pkgs.nixfmt-tree;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            bashInteractive
            nodejs
            sops
          ];
        };
        packages.nvim =
          (import nixpkgs {
            inherit system;
          }).callPackage
            ./modules/neovim
            {
              fennel-ls-nvim-docs = inputs.fennel-ls-nvim-docs;
            };
        # Pi coding agent, exposed in four flavours:
        #   - pi-upstream : version-pinned upstream, no wrapping
        #   - pi-base     : common wrapper (baseline PATH + shared extensions)
        #   - pi-desktop  : desktop variant installed on euler/laplace
        #   - pi-wsl      : WSL/work variant (base + WSL-specific extensions)
        # Add extensions on the fly with
        # `pkgs.pi-coding-agent-base.wrap { extensions = [...]; }` from
        # any downstream nix expression.
        packages.pi-upstream = pkgs.pi-coding-agent-upstream;
        packages.pi-base = pkgs.pi-coding-agent-base;
        packages.pi-desktop = pkgs.pi-coding-agent-desktop;
        packages.pi-wsl = pkgs.pi-coding-agent-wsl;
        apps.nvim = {
          type = "app";
          program = "${self.packages.${system}.nvim}/bin/nvim";
        };
        apps.pi-desktop = {
          type = "app";
          program = "${self.packages.${system}.pi-desktop}/bin/pi";
        };
        apps.pi-wsl = {
          type = "app";
          program = "${self.packages.${system}.pi-wsl}/bin/pi";
        };
      }
    )
    // {
      nixosConfigurations =
        let
          wlib = inputs.nix-wrapper-modules.lib;
          rofiModule = import ./modules/rofi;
          noctaliaModule = import ./modules/noctalia;
          niriModule = import ./modules/niri;
          wrappers = import ./wrappers { inherit (nixpkgs) lib; };
          overlays = [
            (import ./overlays/zellij-plugins.nix)
            (import ./overlays/azure-cli-fix.nix { nixpkgs-master = inputs.nixpkgs-master; })
            (import ./overlays/kulala-nvim.nix)
            (import ./overlays/agent-mcps)
            (import ./overlays/pi-coding-agent.nix)
            (import ./overlays/pi-extensions)
            inputs.nix-openclaw.overlays.default
            inputs.noctalia.overlays.default
            (wrappers.overlay wlib)
            (final: prev: {
              nvim = final.symlinkJoin {
                name = "nvim";
                paths = [
                  (final.callPackage ./modules/neovim {
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
              {
                nixpkgs.overlays = overlays ++ [
                  inputs.niri.overlays.niri
                  (rofiModule.overlay wlib)
                  (noctaliaModule.overlay wlib)
                  (niriModule.mkOverlays wlib {
                    deviceModule = import ./hosts/euler/niri-device.nix;
                  })
                ];
              }
              ./modules/core
              ./modules/network
              ./hosts/euler
              ./modules/secrets
              ./modules/wm/all.nix
              ./modules/office
              ./modules/syncthing
              ./modules/userland
              ./modules/wine
              ./modules/nixos-tools
              ./modules/virtualization
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
                      ./modules/home/helix
                      ./modules/home/ai
                      ./modules/home/skills
                      ./modules/home/tmux
                      ./modules/home/wm-common
                      ./modules/home/zen-browser
                    ];
                    home.stateVersion = "25.11";
                    my.skills.enable = true;
                    my.ai.copilot-cli.enable = true;
                    my.ai.copilot-cli.notifications.enable = true;
                  };
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          };
          laplace = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              {
                nixpkgs.overlays = overlays ++ [
                  inputs.niri.overlays.niri
                  (rofiModule.overlay wlib)
                  (noctaliaModule.overlay wlib)
                  (niriModule.mkOverlays wlib {
                    deviceModule = import ./hosts/laplace/niri-device.nix;
                  })
                ];
              }
              ./modules/core
              ./modules/network
              ./hosts/laplace
              ./modules/userland
              ./modules/syncthing
              ./modules/nixos-tools
              nixos-hardware.nixosModules.framework-13-7040-amd
              ./modules/wm/all.nix
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
                      ./modules/home/skills
                      ./modules/home/helix
                      ./modules/home/tmux
                      ./modules/home/wm-common
                      ./modules/home/zen-browser
                    ];
                    my.skills.enable = true;
                    my.ai.aider.enable = true;
                    my.ai.opencode.enable = true;
                    my.ai.copilot-cli.enable = true;
                    my.ai.copilot-cli.notifications.enable = true;
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
                      ./modules/home/skills
                      ./modules/home/helix
                      ./modules/home/tmux
                      ./modules/home/work
                      inputs.worktrunk-flake.homeModules.default
                      ./modules/home/worktrunk
                    ];
                    my.skills.enable = true;
                    my.skills.extraSkills = [
                      "figma-to-spec"
                      "fluent-ui-v9"
                    ];
                    my.ai.aider.enable = true;
                    my.ai.opencode.enable = true;
                    my.ai.copilot-cli.enable = true;
                    my.ai.mcp.servers.workiq = pkgs.agenticMcps.workiq;
                    my.ai.mcp.servers.icm = pkgs.agenticMcps.icm;
                    my.ai.mcp.servers.azure-devops = pkgs.agenticMcps.azureDevops;
                    my.ai.mcp.servers.fluent-agent = pkgs.agenticMcps.fluentAgent;
                    home.stateVersion = "25.11";
                  };
              }
            ];
          };
        };
    };
}
