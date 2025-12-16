{
  imports = [
    ./flakes.nix
    ./options.nix
    ./fonts.nix
    ./gpg.nix
    ./locale.nix
    ./nh.nix
    ./programs.nix
    ./user.nix
  ];

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
