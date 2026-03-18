{ inputs, ... }:
{
  imports = [
    inputs.charmbracelet-nur.homeModules.crush
  ];
  programs.crush = {
    enable = true;
  };
}
