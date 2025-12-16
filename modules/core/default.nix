{ ... }:
{
  imports = [
    ./flakes.nix
    ./fonts.nix
    ./gpg.nix
    ./locale.nix
    ./networking.nix
    ./nh.nix
    ./programs.nix
    ./user.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
