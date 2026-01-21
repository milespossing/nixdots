{ pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    fd
    ripgrep
    sd
    bat
    jq
    gojq
    yq
    unzip
  ];
}
