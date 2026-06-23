{
  package = import ./waybar.nix;
  overlay = wlib: final: prev: {
    waybar = import ./waybar.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.waybar;
    };
  };
}
