
{ config, pkgs, ... }:

{
  imports = [
    ./basic.nix
    ./modules
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mpossing";
  home.homeDirectory = "/home/mpossing";

  mp.programs.emacs.enable = true;
  mp.programs.git.email = "milespossing@microsoft.com";
  mp.sdev.dotnet.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  programs.home-manager.enable = true;
}
