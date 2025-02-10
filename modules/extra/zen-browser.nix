{ inputs, pkgs, ... }:
{
  # Seems a lot like I should be making this a home-manager module just like firefox
  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}
