{
  pkgs,
  wlib,
  ...
}:
{
  imports = [ wlib.wrapperModules.rofi ];
  package = pkgs.rofi;
  settings = {
    show-icons = true;
    icon-theme = "Papirus-Dark";
    display-drun = " ";
    drun-display-format = "{name}";
    terminal = "kitty";
  };
  theme = "${./rofi-theme.rasi}";
}
