{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./modules
    ./dir-colors.nix
    ./starship.nix
    ./secrets.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.pathDirs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "/usr/local/bin" ];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "vivaldi"
        "spotify"
        "tetrio-desktop"
      ];

    home.sessionVariables =
      let
        path = builtins.concatStringsSep ":" config.pathDirs;
      in
      {
        PATH = "$PATH:${path}";
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

    home.packages = with pkgs; [
      babashka
      bitwarden-cli
      cbonsai
      cmake
      comma
      curl
      fd
      gcc
      lsof
      mosh
      neofetch
      rlwrap
      sd
      socat
      tldr
      typer
      unzip
      vim
      wget
      zulu
    ];

    programs.neovim.enable = true;

    programs.bat = {
      enable = true;
    };

    programs.ripgrep = {
      enable = true;
    };

    programs.nnn = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    programs.jq = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    programs.git = {
      enable = true;
      gcmCoreIntegration.enable = true;
    };

    programs.tmux.enable = true;

    programs.zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
        default_shell = "fish";
      };
    };

    programs.lazygit = {
      enable = true;
    };

    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      # Don't need the fish integration bc it's automatically in there
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
