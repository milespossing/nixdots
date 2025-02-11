{
  config,
  pkgs,
  ...
}:
{
  programs.fish = {
    generateCompletions = true;
    shellAliases = config.shell.aliases;
    shellInit = config.shell.initExtra;
    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      bind \x20wj 'zellij-move down'
      bind \x20wk 'zellij-move up'
      bind \x20wh 'zellij-move left'
      bind \x20wl 'zellij-move right'
      bind \x20t 'zellij-new-tab' 
      bind \x20p 'zellij-new-pane'
    '';

    functions = {
      zellij-move = {
        body = "zellij action move-focus-or-tab $dir";
        argumentNames = "dir";
        description = "Move zellij focus or tab in a given direction";
      };
      zellij-new-tab = {
        body = "zellij action new-tab";
        description = "Create a new tab";
      };
      zellij-new-pane = {
        body = "zellij action new-pane";
        description = "Create a new pane";
      };
    };
  };
}
