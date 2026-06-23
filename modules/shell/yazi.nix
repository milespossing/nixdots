{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        package = pkgs.yazi;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        shellWrapperName = "y";
      };
    };
}
