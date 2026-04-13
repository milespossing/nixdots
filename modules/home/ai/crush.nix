{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;

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

  skillFiles = lib.mapAttrs' (
    name: skill:
    lib.nameValuePair "crush/skills/${name}/SKILL.md" {
      text = if skill.source != null then builtins.readFile skill.source else mkSkillMd name skill;
    }
  ) cfg.skills;

  skillsDirs =
    let
      baseDir = "${config.xdg.configHome}/crush/skills";
    in
    lib.optional (cfg.skills != { }) baseDir;

  serializeCrushMcp =
    _: srv:
    let
      base = {
        type =
          if srv.type == "local" then
            "stdio"
          else if srv.url != null && lib.hasPrefix "http" srv.url then
            "http"
          else
            "sse";
      };
      cmd = lib.optionalAttrs (srv.type == "local" && srv.command != [ ]) {
        command = builtins.head srv.command;
        args = builtins.tail srv.command;
      };
      remote = lib.optionalAttrs (srv.type == "remote" && srv.url != null) {
        url = srv.url;
      };
      env = lib.optionalAttrs (srv.environment != { }) {
        env = srv.environment;
      };
      hdrs = lib.optionalAttrs (srv.headers != { }) {
        headers = srv.headers;
      };
      dis = lib.optionalAttrs (!srv.enabled) {
        disabled = true;
      };
    in
    base // cmd // remote // env // hdrs // dis;

  crushMcp = lib.mapAttrs serializeCrushMcp cfg.mcp.servers;

  ask = pkgs.writeShellScriptBin "ask" ''
    prompt="$*"
    if [ -z "$prompt" ]; then
      prompt=$(${pkgs.gum}/bin/gum input --placeholder "Ask crush anything..." --width 80)
      [ -z "$prompt" ] && exit 0
    fi
    ${pkgs.crush}/bin/crush run "$prompt"
  '';

  crush-files = pkgs.writeShellScriptBin "crush-files" ''
    files=$(${pkgs.fd}/bin/fd --type f --hidden --exclude .git | \
      ${pkgs.gum}/bin/gum filter --no-limit --height 20 --header "Select files for context")
    [ -z "$files" ] && exit 0
    prompt=$(${pkgs.gum}/bin/gum input --placeholder "What do you want to do with these files?" --width 80)
    [ -z "$prompt" ] && exit 0
    context=""
    while IFS= read -r f; do
      context="$context
    --- $f ---
    $(cat "$f")
    "
    done <<< "$files"
    printf '%s\n\n%s' "$context" "$prompt" | ${pkgs.crush}/bin/crush run
  '';
in
{
  imports = [
    inputs.charmbracelet-nur.homeModules.crush
  ];

  config = lib.mkIf cfg.crush.enable {
    home.packages = [
      ask
      crush-files
    ];

    programs.crush = {
      enable = true;
      settings = {
        options = {
          disable_provider_auto_update = false;
          disable_metrics = true;
          tui.compact_mode = true;
          skills_paths = skillsDirs;
        };
      };
    };

    xdg.configFile = skillFiles;
  };
}
