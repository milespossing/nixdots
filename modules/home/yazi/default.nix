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
    };
    flavors = {
      macchiato = "${yazi-flavors}/catppuccin-macchiato.yazi";
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
