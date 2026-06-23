{
  wlib,
  pkgs,
  basePackage ? pkgs.sesh,
  ...
}:
{
  imports = [ wlib.modules.default ];
  config.package = pkgs.sesh;
}
