{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    scala
    sbt
  ];
}
