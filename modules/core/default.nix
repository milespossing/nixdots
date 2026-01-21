{
  imports = [
    ./flakes.nix
    ./options.nix
    ./fonts.nix
    ./gpg.nix
    ./locale.nix
    ./neovim.nix
    ./programs.nix
    ./ssh.nix
    ./user.nix
    ./wireguard.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.fish.enable = true;
  programs.firefox.enable = true;
}
