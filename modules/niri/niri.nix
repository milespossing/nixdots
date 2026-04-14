{
  pkgs,
  wlib,
  basePackage ? pkgs.niri,
  extraConfig ? "",
}:
let
  baseKdl = builtins.readFile ./config.kdl;

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

  # KDL blocks that need Nix store paths
  nixBinds = ''
    // ── Nix-generated binds (store paths) ─────────────────────────────
    binds {
        Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
        Mod+E      { spawn "${pkgs.kitty}/bin/kitty" "-e" "yazi"; }
        Mod+D      { spawn "${pkgs.rofi}/bin/rofi" "-show" "drun" "-show-icons"; }

        Mod+Shift+V { spawn "sh" "-c" "cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | cliphist decode | wl-copy"; }
        Mod+Shift+C { spawn "${color-picker}"; }
        Mod+Shift+W { spawn "${wallpaper-cycle}"; }
    }
  '';

  nixSpawn = ''
    // ── Nix-generated spawn-at-startup ────────────────────────────────
    spawn-at-startup "${pkgs.waybar}/bin/waybar"
    spawn-at-startup "nm-applet" "--indicator"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "text" "--watch" "cliphist" "store"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "image" "--watch" "cliphist" "store"
    spawn-at-startup "/run/current-system/sw/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    spawn-at-startup "${pkgs.awww}/bin/awww-daemon"
    spawn-at-startup "${pkgs.awww}/bin/awww" "img" "~/Pictures/wallpaper.png" "--transition-type" "grow" "--transition-duration" "2"
  '';

  fullConfig = builtins.concatStringsSep "\n" [
    baseKdl
    nixBinds
    nixSpawn
    extraConfig
  ];
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
