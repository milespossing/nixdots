# mkSession — create a wayland session entry from a wrapped niri package.
#
# Takes a wrapped niri package and produces a new derivation that:
# 1. Strips the upstream niri.desktop (which points to bare niri-session)
# 2. Installs a profile-specific .desktop file for the greeter
#
# The wrapped niri-session already works correctly (it starts niri.service
# which ExecStart's the wrapped niri binary with NIRI_CONFIG set).
# We just need unique desktop file names so the greeter shows all variants.
{
  pkgs,
  wrapped,
  name,
  displayName,
}:
let
  desktopFileName = name;

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/${desktopFileName}.desktop" ''
    [Desktop Entry]
    Name=${displayName}
    Comment=A scrollable-tiling Wayland compositor
    Exec=${wrapped}/bin/niri-session
    Type=Application
    DesktopNames=niri
  '';
in
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
