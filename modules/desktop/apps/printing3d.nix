{
  # 3D printing / CAD (euler workstation). Opt-in: hosts import `printing3d`.
  flake.modules.homeManager.printing3d =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        orca-slicer
        freecad-wayland
      ];
    };
}
