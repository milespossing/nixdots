{ ... }:
{
  services.syncthing = {
    enable = true;
    group = "users";
    user = "miles";
    configDir = "/home/miles/.config/syncthing";
  };
}
