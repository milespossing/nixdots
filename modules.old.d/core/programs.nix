{ pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    btop
    fd
    ripgrep
    sd
    bat
    jq
    gojq
    yq
    unzip
    glow
    dust
    duf
    procs
    xh
    hyperfine
    tokei
  ];
}
