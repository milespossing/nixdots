{ self, config, ... }:
{
  flake.wrappers.kitty =
    {
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.kitty ];
      package = pkgs.kitty;
      themeFile = "Catppuccin-Mocha";
      font = {
        name = "DepartureMono Nerd Font";
      };
      settings = {
        confirm_os_window_close = 0;
        scrollback_lines = 50000;
        enable_audio_bell = false;
        update_check_interval = 0;
        clipboard_control = "write-clipboard write-primary";
        strip_trailing_spaces = "smart";
      };
      keybindings = {
        # Pane navigation (tmux-like vim keys)
        "kitty_mod+h" = "neighboring_window left";
        "kitty_mod+j" = "neighboring_window down";
        "kitty_mod+k" = "neighboring_window up";
        "kitty_mod+l" = "neighboring_window right";

        # Pane navigation with arrows
        "kitty_mod+left" = "neighboring_window left";
        "kitty_mod+down" = "neighboring_window down";
        "kitty_mod+up" = "neighboring_window up";
        "kitty_mod+right" = "neighboring_window right";

        # Splits in current working directory (tmux-like directions)
        # - vertical split: create pane to the right
        # - horizontal split: create pane below
        "kitty_mod+backslash" = "launch --location=vsplit --cwd=current";
        "kitty_mod+minus" = "launch --location=hsplit --cwd=current";

        # Layout switching
        "kitty_mod+space" = "next_layout";
        "kitty_mod+tab" = "last_used_layout";
        "kitty_mod+1" = "goto_layout splits";
        "kitty_mod+2" = "goto_layout tall";
        "kitty_mod+3" = "goto_layout fat";
        "kitty_mod+4" = "goto_layout grid";
      };
    };

  flake.modules.nixos.desktop-core =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (config.flake.wrappers.kitty.wrap { inherit pkgs; })
      ];
    };
}
