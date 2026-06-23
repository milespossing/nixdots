{
  imports = [
    ./options.nix
    ./common-programs.nix
    ./starship.nix
    ./git.nix
    ./shells.nix
    ./session-variables.nix
  ];

  programs.home-manager.enable = true;
}
