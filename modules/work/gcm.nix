{
  flake.modules.homeManager.work =
    { pkgs, lib, ... }:
    {
      # Work repos need Git Credential Manager (OAuth). A real ~/.gitconfig
      # gives `git config --global` a writable destination.
      home.activation.ensureWritableGitconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        [ -e "$HOME/.gitconfig" ] || touch "$HOME/.gitconfig"
      '';

      home.sessionVariables.GCM_CREDENTIAL_STORE = "gpg";
      programs.git.settings.credential = {
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        useHttpPath = true;
      };

      # PathInstaller-managed tools install to ~/.config/<tool>/CurrentVersion
      shell.initExtra = ''
        for d in "$HOME"/.config/*/CurrentVersion; do
          [ -d "$d" ] && export PATH="$PATH:$d"
        done
      '';
    };
}
