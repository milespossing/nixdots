{ config, ... }:
{
  nixcats-full = {
    enable = true;
    categoryDefinitions.merge =
      { ... }:
      {
        extraWrapperArgs = {
          ai = [
            "--set"
            "AVANTE_OPENAI_PATH"
            config.sops.secrets.openai_api_key.path
          ];
        };
      };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
