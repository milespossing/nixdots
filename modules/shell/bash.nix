{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      programs.home-manager.enable = true;

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      programs.bash = {
        enable = true;
        shellAliases = config.shell.aliases;
        initExtra = config.shell.initExtra;
        sessionVariables = config.shell.envExtra;
      };

      programs.nushell.enable = true;
    };
}
