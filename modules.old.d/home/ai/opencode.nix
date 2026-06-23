{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  oc = cfg.opencode;

  # Build a clean MCP server attrset for JSON serialization.
  # Strip null/empty fields so the JSON stays minimal.
  serializeMcp =
    name: srv:
    let
      base = {
        inherit (srv) type enabled;
      };
      local = lib.optionalAttrs (srv.type == "local") {
        command = srv.command;
      };
      remote = lib.optionalAttrs (srv.type == "remote" && srv.url != null) {
        url = srv.url;
      };
      env = lib.optionalAttrs (srv.environment != { }) {
        environment = srv.environment;
      };
      hdrs = lib.optionalAttrs (srv.headers != { }) {
        headers = srv.headers;
      };
    in
    base // local // remote // env // hdrs;

  mcpJson = lib.mapAttrs serializeMcp cfg.mcp.servers;

  # Merge MCP servers + instructions + user settings into one config object
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
  }
  // lib.optionalAttrs (cfg.mcp.servers != { }) { mcp = mcpJson; }
  // lib.optionalAttrs (cfg.rules.instructionFiles != [ ]) {
    instructions = cfg.rules.instructionFiles;
  }
  // lib.optionalAttrs (oc.plugins != [ ]) { plugin = oc.plugins; }
  // oc.settings;

  opencodeJson = builtins.toJSON opencodeConfig;

  # Wrap opencode with LSP servers, extra packages, and MCP server packages on PATH
  mcpPackages = lib.filter (p: p != null) (lib.mapAttrsToList (_: srv: srv.package) cfg.mcp.servers);

  allPathPkgs = oc.lspServers ++ oc.extraPackages ++ mcpPackages;

  opencode-wrapped = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [ pkgs.opencode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${lib.makeBinPath allPathPkgs} \
        --run '[ -f "${config.sops.templates."ai-env".path}" ] && . "${
          config.sops.templates."ai-env".path
        }"'
    '';
  };

  coreFiles = {
    "opencode/opencode.json".text = opencodeJson;
  }
  // lib.optionalAttrs (cfg.rules.global != "") {
    "opencode/AGENTS.md".text = cfg.rules.global;
  };
in
{
  config = lib.mkIf oc.enable {
    home.packages = [
      (if allPathPkgs != [ ] then opencode-wrapped else pkgs.opencode)
    ];

    xdg.configFile = coreFiles;
  };
}
