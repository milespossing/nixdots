{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;

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

  # Declarative crush "global config" written to a /nix/store dir and
  # exposed to crush via $CRUSH_GLOBAL_CONFIG (see config block below).
  crushDeclarativeSettings = {
    options = {
      disable_provider_auto_update = false;
      disable_metrics = true;
      tui.compact_mode = true;
    };
    mcp = crushMcp;
  };
  crushDeclarativeConfig = pkgs.runCommand "crush-global-config" { } ''
    mkdir -p $out
    cp ${(pkgs.formats.json { }).generate "crush.json" crushDeclarativeSettings} $out/crush.json
  '';

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

    # Redirect crush's "global config" away from ~/.config/crush so
    # home-manager never clobbers a file the user wants to hand-edit,
    # and crush never tries to rewrite a /nix/store symlink.
    #
    # Crush layers configs (internal/config/load.go), lowest -> highest:
    #   1. $CRUSH_GLOBAL_CONFIG/crush.json    (user "global config"; crush never writes here)
    #   2. ~/.local/share/crush/crush.json    (data; crush writes API keys, model state, ui toggles)
    #   3. <cwd>/.crush/crush.json            (workspace; crush also writes here)
    # All are deep-merged per key, later wins. We point (1) at a
    # /nix/store path so our declarative settings act as a read-only
    # baseline. ~/.config/crush/crush.json is no longer consulted,
    # and ~/.local/share/crush/crush.json remains a real file that
    # crush owns and can rewrite freely.
    home.sessionVariables.CRUSH_GLOBAL_CONFIG = "${crushDeclarativeConfig}";

    programs.crush = {
      enable = true;
      # Upstream's `settings` only writes to ~/.config/crush/crush.json,
      # which we're no longer using. Leave it empty.
      settings = { };
    };

    # Upstream's `mkIf (cfg.settings != {})` is dead — `settings` is a
    # submodule whose nested options carry defaults, so it never
    # reduces to `{}`. Force the home.file entry off so home-manager
    # stops shipping ~/.config/crush/crush.json entirely; CRUSH_GLOBAL_CONFIG
    # already points crush at our /nix/store baseline.
    home.file.".config/crush/crush.json" = lib.mkForce { enable = false; };
  };
}
