{
  pkgs,
  wlib,
  basePackage ? pkgs.rofi,
}:
wlib.evalPackage [
  wlib.wrapperModules.rofi
  {
    inherit pkgs;
    package = basePackage;
    settings = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " ";
      drun-display-format = "{name}";
      terminal = "kitty";
    };
    theme = "${./rofi-theme.rasi}";
  }
]
