{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        cursorline = true;
        auto-pairs = true;
        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };
        completion-trigger-len = 1;
        color-modes = true;
        bufferline = "multiple";
        true-color = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        file-picker = {
          hidden = false;
        };
      };
      keys = {
        normal = {
          space.w = ":write";
          space.q = ":quit";
        };
      };
    };
  };
}
