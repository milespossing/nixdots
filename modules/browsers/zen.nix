{ inputs, ... }:
{
  flake.modules.homeManager.desktop-core = {
    imports = [ inputs.zen-browser.homeModules.beta ];
    programs.zen-browser.enable = true;
  };
}
