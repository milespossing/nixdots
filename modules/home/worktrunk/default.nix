{ pkgs, ... }:
{
  programs.worktrunk = {
    enable = true;
    package = pkgs.worktrunk;

    enableBashIntegration = true;
  };
}
