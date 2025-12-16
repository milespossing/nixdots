{ pkgs, ... }:
{
  home.packages = with pkgs; [
    babashka
    bitwarden-cli
    cbonsai
    cmake
    comma
    curl
    fd
    gcc
    gojq
    lsof
    mosh
    neofetch
    rlwrap
    sd
    socat
    tldr
    typer
    unzip
    wget
    yq
    zulu
  ];

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

}
