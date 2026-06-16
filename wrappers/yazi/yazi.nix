{
  pkgs,
  wlib,
  basePackage ? pkgs.yazi,
}:
let
  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "3001521a0885fc281d0456df5a28394dec850dc6";
    hash = "sha256-lzts4koNg0l0tMkPku8lpb2X4juBs72NREwzca3UCLs=";
  };
  path-from-root = pkgs.fetchFromGitHub {
    owner = "aresler";
    repo = "path-from-root.yazi";
    rev = "3daa62fa01681cff8bb62eb0bd72e59245486846";
    hash = "sha256-2jW+NoEd5ZrcoPnS7Pv7xfWH/lypUJdjF7z3CYZM7Lg=";
  };
in
wlib.evalPackage [
  wlib.wrapperModules.yazi
  (
    { config, ... }:
    {
      inherit pkgs;
      package = basePackage;

      plugins = with pkgs.yaziPlugins; {
        inherit
          smart-enter
          full-border
          git
          chmod
          smart-filter
          jump-to-char
          ;
        path-from-root = "${path-from-root}";
      };

      flavors = {
        macchiato = "${yazi-flavors}/catppuccin-macchiato.yazi";
      };

      settings = {
        yazi.plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];

        keymap.mgr.prepend_keymap = [
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

      constructFiles.luaInit = {
        content = # lua
          ''
            require("full-border"):setup()
            require("git"):setup()
          '';
        relPath = "${config.binName}-config/init.lua";
      };
    }
  )
]
