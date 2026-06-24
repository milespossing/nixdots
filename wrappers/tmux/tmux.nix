{
  pkgs,
  wlib,
  config,
  wt,
  yaziBin,
  ...
}:
let
  sesh = "${pkgs.sesh}/bin/sesh";
  gum = "${pkgs.gum}/bin/gum";
in
{
  imports = [ wlib.wrapperModules.tmux ];
  package = pkgs.tmux;

  # Self-contained: the worktrunk popup pipes through `jq`. runtimePkgs is
  # appended to PATH, so a global jq still wins but the wrapper never depends
  # on one being installed.
  runtimePkgs = [ pkgs.jq ];

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

        # Truncate long session names with an ellipsis so they don't
        # eat the centered window list. `=/N/...` keeps the first N
        # characters and appends "…" when the name is longer.
        set -g @catppuccin_session_text '#{=/20/…:session_name}'

        # Catppuccin's default window tabs show `#T` (pane_title),
        # which apps like copilot-cli set to whatever they please via
        # OSC escapes (e.g. the user's first chat message). Use `#W`
        # (window_name) instead -- that's driven by
        # `automatic-rename-format` below and stays short.
        set -g @catppuccin_window_text ' #W'
        set -g @catppuccin_window_current_text ' #W'
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

    # Yazi file manager in a floating popup (mirrors zellij's Alt-g/Alt-c pattern)
    bind y display-popup -E -d "#{pane_current_path}" -w 90% -h 90% ${yaziBin}

    # Lazygit in a floating popup, opened in the focused pane's CWD
    bind g display-popup -E -d "#{pane_current_path}" -w 90% -h 90% ${pkgs.lazygit}/bin/lazygit

    # sesh for tmux sessions
    bind b display-popup -E -w 40% "${sesh} connect \"$(
      ${sesh} list -i | ${gum} filter --no-strip-ansi --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
    )\""

    bind C-w display-popup -E -w 40% "${wt} switch --no-cd -x \'sesh connect {{ worktree_path }}\' \"$(
      ${wt} list --format json | jq \'map(.branch).[]\' -r | ${gum} filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a branch' --height 50
    )\""

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
    # Enable CSI u / extended key reporting so modifiers like
    # Ctrl/Shift/Alt on otherwise-ambiguous keys (e.g. C-Enter,
    # S-Enter, C-/) reach the inner application. `always` makes tmux
    # emit extended sequences unconditionally; pair it with
    # advertising the `extkeys` terminal feature to the outer term.
    set -s extended-keys always
    set -as terminal-features 'xterm*:extkeys'

    # Emit CSI u (fixterms / kitty-style) sequences rather than the
    # legacy xterm modifyOtherKeys format. Tools like pi parse the
    # csi-u form to disambiguate modified keys reliably.
    set -g extended-keys-format csi-u

    # Status bar position
    set -g status-position top

    # Give the status-left/right segments enough room to render the
    # session name, prefix indicator, etc. without truncation. The
    # tmux defaults (10 / 40) chop long session names and squeeze
    # the centered window list off the bar.
    set -g status-left-length 80
    set -g status-right-length 120

    # Don't let apps (copilot-cli, ssh, etc.) rename windows via OSC
    # title escapes -- they tend to dump multi-line prompts in there
    # and blow up the status bar.
    set -g allow-rename off
    set -g automatic-rename on
    set -g automatic-rename-format '#{b:pane_current_command}'

    # Keep pane border titles short for the same reason.
    set -g pane-border-format '#{pane_index} #{b:pane_current_command}'
  '';
}
