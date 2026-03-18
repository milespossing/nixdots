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

  # Build a SKILL.md with YAML frontmatter from a skill definition
  mkSkillMd =
    name: skill:
    let
      frontmatter = lib.concatStringsSep "\n" (
        [ "---" ]
        ++ [ "name: ${name}" ]
        ++ [ "description: ${skill.description}" ]
        ++ lib.optional (skill.license != null) "license: ${skill.license}"
        ++ lib.optional (skill.compatibility != null) "compatibility: ${skill.compatibility}"
        ++ lib.optional (skill.metadata != { }) (
          "metadata:\n" + lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "  ${k}: ${v}") skill.metadata)
        )
        ++ [ "---" ]
      );
    in
    frontmatter + "\n\n" + skill.content;

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

  # Combine all xdg.configFile entries into one attrset
  skillFiles = lib.mapAttrs' (
    name: skill:
    lib.nameValuePair "opencode/skills/${name}/SKILL.md" {
      text = if skill.source != null then builtins.readFile skill.source else mkSkillMd name skill;
    }
  ) cfg.skills;

  coreFiles = {
    "opencode/opencode.json".text = opencodeJson;
  }
  // lib.optionalAttrs (cfg.rules.global != "") {
    "opencode/AGENTS.md".text = cfg.rules.global;
  };
in
{
  config = lib.mkIf oc.enable {
    assertions = lib.mapAttrsToList (name: skill: {
      assertion =
        (skill.source != null && skill.description == "" && skill.content == "")
        || (skill.source == null && skill.description != "" && skill.content != "");
      message = "my.ai.skills.${name}: set either 'source' (file-based) or both 'description' and 'content' (inline), not a mix.";
    }) cfg.skills;

    home.packages = [
      (if allPathPkgs != [ ] then opencode-wrapped else pkgs.opencode)
    ];

    xdg.configFile = coreFiles // skillFiles;
  };
}
