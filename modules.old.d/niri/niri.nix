{
  pkgs,
  wlib,
  name ? "niri-configured",
  displayName ? "Niri",
  basePackage ? pkgs.niri,
  barCommand ? "${pkgs.waybar}/bin/waybar",
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
        barCommand
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

  wrapped = wlib.evalPackage [
    wlib.wrapperModules.niri
    {
      inherit pkgs;
      package = basePackage;
      v2-settings = true;
      "config.kdl".content = fullConfig;
    }
  ];

  # niri-session delegates to systemd's niri.service, whose ExecStart is
  # hardcoded to whichever niri wrapper ships its service file.  That wrapper
  # unconditionally overrides NIRI_CONFIG, so env-var injection doesn't work.
  #
  # Instead we replicate the session setup niri-session performs and then exec
  # the *profile-specific* wrapped niri binary directly.
  sessionWrapper = pkgs.writeShellScript "${name}-session" ''
    # Re-exec through the user's login shell (mirrors niri-session behaviour)
    if [ -n "$SHELL" ] &&
       grep -q "$SHELL" /etc/shells &&
       ! (echo "$SHELL" | grep -q "false") &&
       ! (echo "$SHELL" | grep -q "nologin"); then
      if [ "$1" != '-l' ]; then
        exec bash -c "exec -l '$SHELL' -c '$0 -l $*'"
      else
        shift
      fi
    fi

    if hash systemctl >/dev/null 2>&1; then
        if systemctl --user -q is-active niri.service; then
          echo 'A niri session is already running.'
          exit 1
        fi

        systemctl --user reset-failed
        systemctl --user import-environment

        if hash dbus-update-activation-environment 2>/dev/null; then
            dbus-update-activation-environment --all
        fi

        # Run the profile-specific wrapped niri directly instead of going
        # through niri.service (which hardcodes a different wrapper/config).
        ${wrapped}/bin/niri --session

        systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
        systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
    else
        echo "systemd not found, starting niri directly."
        exec ${wrapped}/bin/niri --session
    fi
  '';

  # The base profile reuses "niri.desktop" (overrides niri-stable's via hiPrio).
  # Additional profiles get their own uniquely-named desktop files.
  desktopFileName = if name == "niri-configured" then "niri" else name;

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/${desktopFileName}.desktop" ''
    [Desktop Entry]
    Name=${displayName}
    Comment=A scrollable-tiling Wayland compositor
    Exec=${sessionWrapper}
    Type=Application
    DesktopNames=niri
  '';
in
# The wlib-wrapped niri inherits upstream's share/wayland-sessions/niri.desktop
# (bare Exec=niri-session) which conflicts with our profile-specific desktop
# file and would bypass our config.  Strip it and provide only our own.
pkgs.runCommand name { } ''
  mkdir -p $out
  for d in ${wrapped}/*; do
    ln -s "$d" "$out/$(basename $d)"
  done
  # Replace share to exclude upstream wayland-sessions
  rm $out/share
  mkdir -p $out/share
  for d in ${wrapped}/share/*; do
    if [ "$(basename $d)" != "wayland-sessions" ]; then
      ln -s "$d" "$out/share/$(basename $d)"
    fi
  done
  # Install only our profile-specific desktop file
  mkdir -p $out/share/wayland-sessions
  cp ${sessionFile}/share/wayland-sessions/${desktopFileName}.desktop \
    $out/share/wayland-sessions/${desktopFileName}.desktop
''
