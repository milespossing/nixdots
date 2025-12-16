{
  lib,
  pkgs,
  ...
}:
with lib;
{
  programs.gpg.enable = true;
  programs.password-store.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.departure-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg

    wslu
    wsl-open
    xdg-utils
  ];

  fonts.fontconfig.enable = true;

  shell.initExtra = ''
    export WSL=1
  '';

  programs.git.settings.credential = {
    helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
    useHttpPath = true;
  };
}
