{
  pkgs,
  wlib,
  basePackage ? pkgs.niri,
  extraConfig ? "",
}:
let
  screenshot-region = pkgs.writeShellScript "niri-screenshot-region" ''
    grim -g "$(slurp)" - | swappy -f -
  '';

  color-picker = pkgs.writeShellScript "niri-color-picker" ''
    grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
    notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
  '';

  wallpaper-cycle = pkgs.writeShellScript "niri-wallpaper-cycle" ''
    img="$(find ~/Pictures/wallpapers -type f | shuf -n1)"
    ${pkgs.awww}/bin/awww img "$img" --transition-type grow --transition-pos cursor --transition-duration 2
  '';

  # Substitute placeholders in config.kdl with Nix store paths
  fullConfig =
    builtins.replaceStrings
      [
        "@KITTY@"
        "@ROFI@"
        "@WAYBAR@"
        "@WL_PASTE@"
        "@AWWW_DAEMON@"
        "@AWWW@"
        "@COLOR_PICKER@"
        "@WALLPAPER_CYCLE@"
        "@CLIPHIST_CMD@"
      ]
      [
        "${pkgs.kitty}/bin/kitty"
        "${pkgs.rofi}/bin/rofi"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.wl-clipboard}/bin/wl-paste"
        "${pkgs.awww}/bin/awww-daemon"
        "${pkgs.awww}/bin/awww"
        (toString color-picker)
        (toString wallpaper-cycle)
        "cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | cliphist decode | wl-copy"
      ]
      (builtins.readFile ./config.kdl)
    + "\n"
    + extraConfig;
in
wlib.evalPackage [
  wlib.wrapperModules.niri
  {
    inherit pkgs;
    package = basePackage;
    v2-settings = true;
    "config.kdl".content = fullConfig;
  }
]
