{ pkgs, ... }:
let
  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "3001521a0885fc281d0456df5a28394dec850dc6";
    hash = "sha256-lzts4koNg0l0tMkPku8lpb2X4juBs72NREwzca3UCLs=";
  };
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "b224ddfb4bb6a9b438ac00ccb607b0eb517207d2";
    hash = "sha256-hn6oEFCLhACPh8T/qoPVHbX8Npsjd1EDXsZlm9SzIII=";
  };
  path-from-root = pkgs.fetchFromGitHub {
    owner = "aresler";
    repo = "path-from-root.yazi";
    rev = "3daa62fa01681cff8bb62eb0bd72e59245486846";
    hash = "sha256-2jW+NoEd5ZrcoPnS7Pv7xfWH/lypUJdjF7z3CYZM7Lg=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";

    plugins = {
      smart-enter = "${yazi-plugins}/smart-enter.yazi";
      full-border = "${yazi-plugins}/full-border.yazi";
      git = "${yazi-plugins}/git.yazi";
      chmod = "${yazi-plugins}/chmod.yazi";
      smart-filter = "${yazi-plugins}/smart-filter.yazi";
      jump-to-char = "${yazi-plugins}/jump-to-char.yazi";
      path-from-root = "${path-from-root}";
    };
    flavors = {
      macchiato = "${yazi-flavors}/catppuccin-macchiato.yazi";
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<C-h>";
          run = "shell 'zellij action move-focus-or-tab left' --confirm";
          desc = "Move zellij focus left";
        }
        {
          on = "<C-j>";
          run = "shell 'zellij action move-focus down' --confirm";
          desc = "Move zellij focus down";
        }
        {
          on = "<C-k>";
          run = "shell 'zellij action move-focus up' --confirm";
          desc = "Move zellij focus up";
        }
        {
          on = "<C-l>";
          run = "shell 'zellij action move-focus-or-tab right' --confirm";
          desc = "Move zellij focus right";
        }
        {
          on = [
            "c"
            "r"
          ];
          run = "plugin path-from-root";
          desc = "Copy path relative to git root";
        }
      ];
    };

    settings = {
      plugin.prepend_fetchers = [
        {
          id = "git";
          url = "*";
          run = "git";
        }
        {
          id = "git";
          url = "*/";
          run = "git";
        }
      ];
    };

    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
    '';
  };
}
