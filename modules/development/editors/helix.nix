{
  flake.modules.homeManager.dev = {
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
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
        keys.normal.space = {
          w = ":write";
          q = ":quit";
        };
      };
    };
  };
}
