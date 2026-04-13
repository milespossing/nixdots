{ config, ... }:
{
  config.my.alias.email = "milespossing@microsoft.com";

  # PathInstaller-managed tools (e.g. agency) install to ~/.config/<tool>/CurrentVersion
  config.shell.initExtra = ''
    for d in "$HOME"/.config/*/CurrentVersion; do
      [ -d "$d" ] && export PATH="$PATH:$d"
    done
  '';
}
