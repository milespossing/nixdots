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

  home.sessionVariables.GCM_CREDENTIAL_STORE = "gpg";
  programs.git.settings.credential = {
    helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
    useHttpPath = true;
  };
}
