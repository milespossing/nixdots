{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.neovim.use-fennel = lib.mkEnableOption "Enables the fennel version of nvim (unstable)";
  imports = [
    ./modules
    ./dir-colors.nix
    ./lsp.nix
    ./starship.nix
  ];
  config = {

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "vivaldi"
        "spotify"
        "tetrio-desktop"
      ];

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
      neovim
      pass
      rlwrap
      rustup
      tldr
      typer
      unzip
      vim
      wget
      zulu
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".config/nvim" = {
      source = if config.neovim.use-fennel then ./dots/nvim-fennel else ./dots/nvim;
      recursive = true;
    };

    programs.bat = {
      enable = true;
    };

    programs.ripgrep = {
      enable = true;
    };

    programs.navi = {
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

    mp.programs.git.enable = true;
    mp.programs.tmux.enable = true;

    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        theme = "nord";
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

    programs.gpg = {
      enable = true;
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
