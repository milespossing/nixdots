{ pkgs, lib, ... }:
{
  imports = [
    ./modules
    ./dir-colors.nix
    ./lsp.nix
    ./starship.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "vivaldi"
      "spotify"
      "tetrio-desktop"
    ];

  home.packages = with pkgs; [
    asdf-vm # somethings just are easier with asdf
    babashka
    bitwarden-cli
    cbonsai
    cmake
    comma
    curl
    fd
    gcc
    lsof
    neofetch
    neovim
    pass
    rlwrap
    rustup
    tldr
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
    source = ./dots/nvim;
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
  };

  programs.jq = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  mp.programs.git.enable = true;
  mp.programs.tmux.enable = true;

  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
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
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
