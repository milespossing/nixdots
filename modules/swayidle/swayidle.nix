{
  pkgs,
  wlib,
  basePackage ? pkgs.swayidle,
}:
let
  dpms-off = pkgs.writeShellScript "dpms-off" ''
    if pgrep -x sway > /dev/null; then
      swaymsg 'output * power off'
    elif pgrep -x niri > /dev/null; then
      niri msg action power-off-monitors
    elif pgrep -x Hyprland > /dev/null; then
      hyprctl dispatch dpms off
    fi
  '';
  dpms-on = pkgs.writeShellScript "dpms-on" ''
    if pgrep -x sway > /dev/null; then
      swaymsg 'output * power on'
    elif pgrep -x niri > /dev/null; then
      niri msg action power-on-monitors
    elif pgrep -x Hyprland > /dev/null; then
      hyprctl dispatch dpms on
    fi
  '';
in
wlib.evalPackage [
  wlib.wrapperModules.swayidle
  {
    inherit pkgs;
    package = basePackage;
    events = {
      before-sleep = "loginctl lock-session";
      lock = "pidof swaylock || swaylock -f";
    };
    timeouts = [
      {
        timeout = 600;
        command = "swaylock -f";
      }
      {
        timeout = 900;
        command = builtins.toString dpms-off;
        resumeCommand = builtins.toString dpms-on;
      }
    ];
  }
]
