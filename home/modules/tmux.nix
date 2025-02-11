{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.tmux;
  tmux-which-key = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-which-key";
    version = "unstable-2025-02-11";
    src = pkgs.fetchFromGitHub {
      owner = "alexwforsythe";
      repo = "tmux-which-key";
      rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
      sha256 = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
    };
  };
in
{
  config.programs.tmux = mkIf cfg.enable {
    keyMode = "vi";
    prefix = "C-b";
    clock24 = true;
    newSession = true;
    historyLimit = 10000;
    terminal = "screen-256color";
    escapeTime = 100;
    extraConfig = ''
      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      set -s command-alias bg="new -d"
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
      }
      {
        plugin = tmuxPlugins.yank;
      }
      {
        plugin = tmuxPlugins.jump;
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
      }
      {
        plugin = tmuxPlugins.fuzzback;
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
        extraConfig = "set -g mouse";
      }
      {
        plugin = tmuxPlugins.tmux-floax;
      }
      {
        plugin = tmux-which-key;
      }
    ];
  };
}
