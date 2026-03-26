{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  cop = cfg.copilot-cli;

  # Serialize a shared MCP server to Copilot CLI's format.
  # Copilot uses { command, args, env, tools } whereas OpenCode uses { command: [cmd, ...args] }.
  serializeMcp =
    _name: srv:
    let
      base = lib.optionalAttrs (srv.type == "local") {
        type = "local";
        command = builtins.head srv.command;
        args = builtins.tail srv.command;
        tools = [ "*" ];
      };
      remote = lib.optionalAttrs (srv.type == "remote" && srv.url != null) {
        type = "http";
        url = srv.url;
        tools = [ "*" ];
      };
      env = lib.optionalAttrs (srv.environment != { }) {
        env = srv.environment;
      };
      hdrs = lib.optionalAttrs (srv.headers != { }) {
        headers = srv.headers;
      };
    in
    base // remote // env // hdrs;

  enabledMcpServers = lib.filterAttrs (_: srv: srv.enabled) cfg.mcp.servers;
  mcpJson = lib.mapAttrs serializeMcp enabledMcpServers;
  mcpConfigJson = builtins.toJSON { mcpServers = mcpJson; };

  # Build a Copilot CLI plugin derivation from shared skills.
  # Structure: .claude-plugin/marketplace.json + skills/<name>/SKILL.md
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

  skillNames = builtins.attrNames cfg.skills;

  marketplace = builtins.toJSON {
    name = "nix-managed-skills";
    metadata = {
      description = "Agent skills managed declaratively via NixOS/home-manager";
      version = "1.0.0";
    };
    plugins = [
      {
        name = "nix-managed-skills";
        description = "Skills from my.ai.skills";
        source = "./";
        skills = map (n: "./skills/${n}") skillNames;
      }
    ];
  };

  skillsPlugin = pkgs.runCommand "copilot-skills-plugin" { } (
    ''
      mkdir -p $out/.claude-plugin
      cat > $out/.claude-plugin/marketplace.json <<'MANIFEST'
      ${marketplace}
      MANIFEST
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: skill:
        let
          content =
            if skill.source != null then
              "cp ${skill.source} $out/skills/${name}/SKILL.md"
            else
              ''
                cat > $out/skills/${name}/SKILL.md <<'SKILLEOF'
                ${mkSkillMd name skill}
                SKILLEOF
              '';
        in
        ''
          mkdir -p $out/skills/${name}
          ${content}
        ''
      ) cfg.skills
    )
  );

  # Collect MCP server packages for PATH injection
  mcpPackages = lib.filter (p: p != null) (
    lib.mapAttrsToList (_: srv: srv.package) enabledMcpServers
  );

  copilot-wrapped = pkgs.symlinkJoin {
    name = "copilot-wrapped";
    paths = [ pkgs.github-copilot-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild =
      let
        pluginArgs = lib.optionalString (cfg.skills != { }) "--add-flags '--plugin-dir ${skillsPlugin}'";
        secretsRun = ''
          --run '[ -f "${config.sops.templates."ai-env".path}" ] && . "${
            config.sops.templates."ai-env".path
          }"'
        '';
        pathPrefix = lib.optionalString (
          mcpPackages != [ ]
        ) "--prefix PATH : ${lib.makeBinPath mcpPackages}";
      in
      ''
        wrapProgram $out/bin/copilot \
          ${pluginArgs} \
          ${pathPrefix} \
          ${secretsRun}
      '';
  };
in
{
  config = lib.mkIf cop.enable {
    home.packages = [
      copilot-wrapped
    ];

    home.file = lib.mkIf (enabledMcpServers != { }) {
      ".copilot/mcp-config.json".text = mcpConfigJson;
    };
  };
}
