{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.my.ai.alexandria;
  alexPkg = inputs.alexandria.packages.${pkgs.system}.default;

  # Wrap alex with sops secrets so GITHUB_TOKEN is available for
  # all subcommands (index, setup, serve, etc.), not just when
  # launched as an MCP subprocess of opencode.
  alex-wrapped = pkgs.symlinkJoin {
    name = "alexandria-wrapped";
    paths = [ alexPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/alex \
        --run '[ -f "${config.sops.templates."ai-env".path}" ] && . "${
          config.sops.templates."ai-env".path
        }"'
      wrapProgram $out/bin/alexandria \
        --run '[ -f "${config.sops.templates."ai-env".path}" ] && . "${
          config.sops.templates."ai-env".path
        }"'
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.alexandria = {
      enable = true;
      package = alex-wrapped;
      embed.backend = cfg.embed.backend;
      embed.model = cfg.embed.model;
    };

    # Auto-register the MCP server so opencode can use alex serve.
    my.ai.mcp.servers.alexandria = {
      type = "local";
      command = [
        "alex"
        "serve"
      ];
      enabled = true;
      url = null;
      headers = { };
      environment = { };
      package = null; # alex is already on PATH via programs.alexandria
    };
  };
}
