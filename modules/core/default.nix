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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://zen-browser.cachix.org"
      "https://charmbracelet.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "zen-browser.cachix.org-1:JqFj1EF0dz5hhk0n+NuYPBvmHGMsEPPiku56OK0GDzo="
      "charmbracelet.cachix.org-1:iA+l3/8TVJsKR9h28f7f0C0CYA9JjI24yJ8YlGabbkg="
    ];
    max-jobs = "auto";
    auto-optimise-store = true;
  };

  programs.fish.enable = true;
  programs.firefox.enable = true;
}
