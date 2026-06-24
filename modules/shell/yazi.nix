{ config, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        package = config.flake.wrappers.yazi.wrap { inherit pkgs; };
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        shellWrapperName = "y";
      };
    };
}
