{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "~/Pictures/wallpaper.png" ];
      wallpaper = [ ",~/Pictures/wallpaper.png" ];
    };
  };
}
