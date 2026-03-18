# Overlay: pkgs.agenticMcps — declarative MCP server "packages".
#
# Each entry is an attrset matching the home-manager mcpServerType option shape.
# Use mkLocalMcp for stdio servers and mkRemoteMcp for SSE/HTTP servers.
# Set `package` on local servers to auto-inject their binary into OpenCode's PATH.
final: prev:
let
  aiLib = import ../../modules/home/ai/lib.nix {
    lib = final.lib;
    pkgs = final;
  };
in
{
  agenticMcps = {
    # Alexandria — local semantic code-search MCP server.
    # Requires programs.alexandria.enable in home-manager (provides alex on PATH).
    # https://github.com/milespossing/alexandria
    alexandria = aiLib.mkLocalMcp {
      command = [
        "alex"
        "serve"
      ];
    };
  };
}
