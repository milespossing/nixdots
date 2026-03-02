{ pkgs, lib, ... }:
let
  # LSP servers scoped exclusively to OpenCode's PATH
  opencode-lsps = with pkgs; [
    nixd
    lua-language-server
    gopls
    typescript-language-server
    clojure-lsp
  ];

  opencode-wrapped = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [ pkgs.opencode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${lib.makeBinPath opencode-lsps}
    '';
  };
in
{
  home.packages = [
    pkgs.github-copilot-cli
    opencode-wrapped
  ];
}
