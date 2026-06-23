# mkSession — create a wayland session entry from a wrapped niri package.
#
# Takes a wrapped niri package and produces a new derivation that:
# 1. Strips the upstream niri.desktop and niri.service (both conflict across variants)
# 2. Creates a per-variant systemd user service that properly activates
#    graphical-session.target (fixing PipeWire/WirePlumber race at boot)
# 3. Creates a per-profile session script that starts the variant service
# 4. Installs a profile-specific .desktop file for the greeter
#
# Why not use niri-session? It delegates to `systemctl --user start niri.service`,
# but all variants ship the same niri.service filename — only one wins the merge.
# Each variant gets its own service (e.g. niri-noct.service) to avoid the conflict
# while preserving proper systemd target activation.
{
  pkgs,
  wrapped,
  name,
  displayName,
}:
let
  serviceFile = pkgs.writeTextDir "share/systemd/user/${name}.service" ''
    [Unit]
    Description=${displayName} (Niri session)
    BindsTo=graphical-session.target
    Before=graphical-session.target
    Wants=graphical-session-pre.target
    After=graphical-session-pre.target
    Wants=xdg-desktop-autostart.target
    Before=xdg-desktop-autostart.target

    [Service]
    Slice=session.slice
    Type=notify
    ExecStart=${wrapped}/bin/niri --session
  '';

  sessionScript = pkgs.writeShellScript "${name}-session" ''
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
        if systemctl --user -q is-active ${name}.service; then
          echo 'A niri session is already running.'
          exit 1
        fi

        systemctl --user reset-failed
        systemctl --user import-environment

        if hash dbus-update-activation-environment 2>/dev/null; then
            dbus-update-activation-environment --all
        fi

        systemctl --user --wait start ${name}.service

        systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
        systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
    else
        echo "systemd not found, starting niri directly."
        exec ${wrapped}/bin/niri --session
    fi
  '';

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/${name}.desktop" ''
    [Desktop Entry]
    Name=${displayName}
    Comment=A scrollable-tiling Wayland compositor
    Exec=${sessionScript}
    Type=Application
    DesktopNames=niri
  '';
in
pkgs.runCommand name { } ''
  mkdir -p $out
  for d in ${wrapped}/*; do
    ln -s "$d" "$out/$(basename $d)"
  done
  # Replace share: strip upstream wayland-sessions and systemd service
  rm $out/share
  mkdir -p $out/share
  for d in ${wrapped}/share/*; do
    case "$(basename $d)" in
      wayland-sessions|systemd) ;; # skip — we provide our own
      *) ln -s "$d" "$out/share/$(basename $d)" ;;
    esac
  done
  # Install per-variant desktop file and systemd service
  mkdir -p $out/share/wayland-sessions
  cp ${sessionFile}/share/wayland-sessions/${name}.desktop \
    $out/share/wayland-sessions/${name}.desktop
  mkdir -p $out/share/systemd/user
  cp ${serviceFile}/share/systemd/user/${name}.service \
    $out/share/systemd/user/${name}.service
''
