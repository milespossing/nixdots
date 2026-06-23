{ config, lib, ... }:
{
  config.my.alias.email = "milespossing@microsoft.com";

  # Ensure a writable, regular ~/.gitconfig exists on work machines.
  #
  # Work repos must use Git Credential Manager in OAuth mode (the Azure DevOps
  # org disabled PAT creation). OAuth mode makes GCM cache the AAD authority by
  # writing credential.azrepos:org/<org>.azureAuthority to the *global* git
  # config. Home-manager's XDG config (~/.config/git/config) is a read-only
  # /nix/store symlink, so that write fails and crashes every credential
  # request. A real ~/.gitconfig gives `git config --global` a writable
  # destination (git reads both files at global scope).
  #
  # Created empty and only when missing — this never overwrites an existing
  # file, and home-manager does not manage ~/.gitconfig otherwise.
  config.home.activation.ensureWritableGitconfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "$HOME/.gitconfig" ]; then
        touch "$HOME/.gitconfig"
      fi
    '';

  # PathInstaller-managed tools (e.g. agency) install to ~/.config/<tool>/CurrentVersion
  config.shell.initExtra = ''
    for d in "$HOME"/.config/*/CurrentVersion; do
      [ -d "$d" ] && export PATH="$PATH:$d"
    done
  '';
}
