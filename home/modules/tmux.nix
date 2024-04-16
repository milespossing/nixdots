{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.programs.tmux;
in {
  options.mp.programs.tmux = {
    enable = mkEnableOption "Enables tmux";
  };

  config.programs.tmux = mkIf cfg.enable {
    enable = true;
    keyMode = "vi";
    prefix = "C-b";
    clock24 = true;
    newSession = true;
    historyLimit = 10000;
    extraConfig = ''
      bind - split-window -v -c "#{pane_current_path}"
      bind \ split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.nord;
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
    ];
  };
}
