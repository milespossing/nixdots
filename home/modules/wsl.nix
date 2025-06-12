{
  lib,
  pkgs,
  ...
}:
with lib;
{
  mp.git.gcmCoreIntegration.enable = true;

  home.programs.gpg.enable = true;
  home.programs.password-store.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.departure-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg

    wslu
  ];

  fonts.fontconfig.enable = true;

  programs.git.credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
}
