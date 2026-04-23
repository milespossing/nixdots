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
  # --plugin-dir looks for plugin.json (not marketplace.json) at:
  #   plugin.json | .github/plugin/plugin.json | .claude-plugin/plugin.json
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

  pluginJson = builtins.toJSON {
    name = "nix-managed-skills";
    description = "Agent skills managed declaratively via NixOS/home-manager";
    version = "1.0.0";
    skills = map (n: "./skills/${n}") skillNames;
  };

  skillsPlugin = pkgs.runCommand "copilot-skills-plugin" { } (
    ''
      mkdir -p $out/.claude-plugin
      cat > $out/.claude-plugin/plugin.json <<'MANIFEST'
      ${pluginJson}
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

  # Default notification hooks using notify-send
  notifyHooks = lib.optionalAttrs cop.notifications.enable {
    sessionEnd = [
      {
        type = "command";
        bash = ''
          INPUT=$(cat)
          REASON=$(echo "$INPUT" | ${lib.getExe pkgs.jq} -r '.reason')
          case "$REASON" in
            complete)
              ${lib.getExe pkgs.libnotify} --app-name "Copilot" --urgency normal --icon dialog-positive \
                "Task Complete" "Copilot finished working." ;;
            error)
              ${lib.getExe pkgs.libnotify} --app-name "Copilot" --urgency critical --icon dialog-error \
                "Session Error" "Copilot session ended with an error." ;;
            abort|timeout)
              ${lib.getExe pkgs.libnotify} --app-name "Copilot" --urgency normal --icon dialog-warning \
                "Session Ended" "Copilot session was ''${REASON}." ;;
            user_exit)
              ${lib.getExe pkgs.libnotify} --app-name "Copilot" --urgency low --icon dialog-information \
                "Session Closed" "Copilot session ended." ;;
          esac
        '';
        timeoutSec = 5;
      }
    ];
    errorOccurred = [
      {
        type = "command";
        bash = ''
          INPUT=$(cat)
          MSG=$(echo "$INPUT" | ${lib.getExe pkgs.jq} -r '.error.message // "Unknown error"')
          ${lib.getExe pkgs.libnotify} --app-name "Copilot" --urgency critical --icon dialog-error \
            "Error" "$MSG"
        '';
        timeoutSec = 5;
      }
    ];
  };

  # Merge notification hooks with user-defined hooks (user hooks take precedence)
  allHooks = lib.recursiveUpdate notifyHooks cop.hooks;

  # Nix-managed config overlay merged into ~/.copilot/config.json at launch.
  # Only the "hooks" key is managed; auth/model/tokens remain mutable.
  hooksOverlay = pkgs.writeText "copilot-hooks-overlay.json" (builtins.toJSON { hooks = allHooks; });

  mergeHooksScript = pkgs.writeShellScript "copilot-merge-hooks" ''
    COPILOT_CFG="$HOME/.copilot/config.json"
    if [ -f "$COPILOT_CFG" ]; then
      ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$COPILOT_CFG" ${hooksOverlay} > "$COPILOT_CFG.tmp" \
        && mv "$COPILOT_CFG.tmp" "$COPILOT_CFG"
    else
      mkdir -p "$HOME/.copilot"
      cp ${hooksOverlay} "$COPILOT_CFG"
    fi
  '';

  hooksRun = lib.optionalString (allHooks != { }) "--run ${mergeHooksScript}";

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
          ${hooksRun} \
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
