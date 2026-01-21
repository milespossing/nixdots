{
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
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
