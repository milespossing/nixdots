{ ... }:
{
  services.swayidle = {
    enable = true;
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
        command = "swaymsg 'output * power off'";
        resumeCommand = "swaymsg 'output * power on'";
      }
    ];
  };
}
