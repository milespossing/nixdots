{ pkgs, config, lib, ... }:
{
  imports = [
    ../../home/basic.nix
    ../../home/user-space.nix
  ];

  # home.activation = {
  #   copyApplications =
  #     let
  #       apps = pkgs.buildEnv {
  #         name = "home-manager-applications";
  #         paths = config.home.packages;
  #         pathsToLink = "/Applications";
  #       };
  #     in
  #     lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #       baseDir="$HOME/Applications/hm-apps"
  #       if [ -d "$baseDir" ]; then
  #         rm -rf "$baseDir"
  #       fi
  #       mkdir -p "$baseDir"
  #       for appFile in ${apps}/Applications/*; do
  #         target="$baseDir/$(basename "$appFile")"
  #         $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
  #         $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
  #       done
  #     '';
  # };

  home.username = "miles";
  home.homeDirectory = "/Users/miles";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
