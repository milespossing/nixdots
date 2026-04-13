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

    # Work IQ — Microsoft 365 data via M365 Copilot Chat API.
    # Requires M365 Copilot license and tenant admin consent.
    # https://github.com/microsoft/work-iq
    workiq = aiLib.mkLocalMcp {
      command = [
        "npx"
        "-y"
        "@microsoft/workiq@latest"
        "mcp"
      ];
      package = final.nodejs;
    };

    # ICM — Incident management MCP server (Azure HTTP endpoint).
    icm = aiLib.mkRemoteMcp {
      url = "https://icm-mcp-prod.azure-api.net/v1/";
    };
  };
}
