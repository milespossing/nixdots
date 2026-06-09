{
  pkgs,
  wlib,
  basePackage ? pkgs.tmux,
}:
wlib.evalPackage [
  wlib.wrapperModules.tmux
  (
    { config, ... }:
    {
      inherit pkgs;
      package = basePackage;

      prefix = "C-a";
      sourceSensible = true;
      mouse = true;
      vimVisualKeys = true;
      escapeTime = 0;
      historyLimit = 50000;
      baseIndex = 1;
      paneBaseIndex = 1;
      terminal = "tmux-256color";
      terminalOverrides = "*:Tc";
      modeKeys = "vi";

      plugins = with pkgs.tmuxPlugins; [
        { plugin = yank; }
        { plugin = pain-control; }
        { plugin = extrakto; }
        { plugin = tmux-fzf; }
        { plugin = fzf-tmux-url; }
        {
          plugin = catppuccin;
          configBefore = ''
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_status_style 'rounded'
          '';
        }
      ];

      configBefore = ''
        # Re-bind prefix-a to send-prefix so it still reaches the inner app
        bind -N "Send the prefix key through to the application" a send-prefix

        # Quick config reload (path of the wrapper-generated tmux.conf)
        bind R source-file ${config.constructFiles.generatedConfig.path} \; display-message "tmux config reloaded"

        # Split panes in the current working directory
        bind '"' split-window -v -c "#{pane_current_path}"
        bind '%' split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Easier window swap
        bind -r "<" swap-window -d -t -1
        bind -r ">" swap-window -d -t +1

        # Copy-mode bindings (vi-style)
        bind -T copy-mode-vi 'C-v' send -X rectangle-toggle
        bind -T copy-mode-vi 'Escape' send -X cancel

        # fzf-driven action menu (overrides the default next-layout binding).
        # Entries are declared in nix via `my.tmux.menu.entries` (see
        # modules/home/tmux). The `tmux-menu` binary is installed by the
        # home-manager module into the user's PATH.
        bind Space display-popup -E -w 60% -h 50% tmux-menu

        # Yazi file manager in a floating popup (mirrors zellij's Alt-g/Alt-c pattern)
        bind y display-popup -E -d "#{pane_current_path}" -w 90% -h 90% ${pkgs.yazi}/bin/yazi

        # Lazygit in a floating popup, opened in the focused pane's CWD
        bind g display-popup -E -d "#{pane_current_path}" -w 90% -h 90% ${pkgs.lazygit}/bin/lazygit

        # smart-splits.nvim integration: seamless nav + resize between
        # tmux panes and nvim splits. Forwards C-hjkl / M-hjkl to nvim
        # when the focused pane is running (n)vim; otherwise selects or
        # resizes the tmux pane directly.
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
        bind-key -n C-h if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
        bind-key -n C-j if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
        bind-key -n C-k if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
        bind-key -n C-l if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

        bind-key -n M-h if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 3'
        bind-key -n M-j if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 3'
        bind-key -n M-k if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 3'
        bind-key -n M-l if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 3'

        bind-key -T copy-mode-vi C-h select-pane -L
        bind-key -T copy-mode-vi C-j select-pane -D
        bind-key -T copy-mode-vi C-k select-pane -U
        bind-key -T copy-mode-vi C-l select-pane -R
      '';

      configAfter = ''
        # Status bar position
        set -g status-position top
      '';
    }
  )
]
