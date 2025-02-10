{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  shellHook = ''
    export XDG_CONFIG_HOME="$PWD"
    export XDG_DATA_HOME="/tmp/.local"
    echo "Using redirected paths:"
    echo "  XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
    echo "  XDG_DATA_HOME=$XDG_DATA_HOME"
  '';
}
