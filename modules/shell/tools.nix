{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.fzf = {
        enable = true;
        defaultCommand = "fd --type f";
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
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
        enableNushellIntegration = true;
        nix-direnv.enable = true;
      };
      programs.atuin = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          sync_frequency = "5m";
          filter_mode = "directory";
          filter_mode_shell_up_arrow = "session";
        };
      };
      home.packages = [ pkgs.gum ];
    };
}
