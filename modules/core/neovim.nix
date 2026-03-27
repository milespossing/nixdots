{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.my-nixcats.nixosModules.default ];
  environment.systemPackages = [ pkgs.nvim ];
}
