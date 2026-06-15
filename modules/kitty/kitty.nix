{
  pkgs,
  wlib,
  basePackage ? pkgs.kitty,
}:
wlib.evalPackage [
  wlib.wrapperModules.kitty
  {
    inherit pkgs;
    package = basePackage;
    themeFile = "Catppuccin-Mocha";
    font = {
      name = "DepartureMono Nerd Font";
    };
    settings = {
      confirm_os_window_close = 0;
    };
  }
]
