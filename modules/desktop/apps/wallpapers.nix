{
  flake.modules.homeManager.desktop-core = {
    home.file."Pictures/wallpapers" = {
      source = ./_wallpapers/images;
      recursive = true;
    };
  };
}
