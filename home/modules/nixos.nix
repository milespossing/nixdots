{
  pkgs,
  ...
}:
{
  home.sessionVariables.GCM_CREDENTIAL_STORE = "gpg";
  programs.git.extraConfig.credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
}
