{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.my-nixcats.nixosModules.default ];
  nixcats-full = {
    enable = true;
  };
  environment.systemPackages = [ pkgs.nvim-next ];
}
