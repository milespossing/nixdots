{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;

  crush-wrapped = pkgs.symlinkJoin {
    name = "crush-wrapped";
    paths = [ pkgs.crush ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/crush \
        --run '[ -f "${config.sops.templates."ai-env".path}" ] && . "${
          config.sops.templates."ai-env".path
        }"'
    '';
  };
in
{
  imports = [
    inputs.charmbracelet-nur.homeModules.crush
  ];

  config = lib.mkIf cfg.crush.enable {
    programs.crush = {
      enable = true;
      package = crush-wrapped;
      settings = {
        options = {
          disable_provider_auto_update = true;
          disable_metrics = true;
        };
        providers = {
          copilot = {
            type = "openai-compat";
            name = "GitHub Copilot";
            api_key = "$GITHUB_TOKEN";
            base_url = "https://api.githubcopilot.com";
            extra_headers = {
              "Copilot-Integration-Id" = "vscode-chat";
              "Editor-Version" = "vscode/1.105.1";
              "Editor-Plugin-Version" = "copilot-chat/0.32.4";
            };
            models = [
              {
                id = "claude-opus-4.6-1m";
                name = "Claude Opus 4.6 (1M)";
                context_window = 936000;
                default_max_tokens = 16384;
                can_reason = true;
              }
              {
                id = "claude-sonnet-4.6";
                name = "Claude Sonnet 4.6";
                context_window = 168000;
                default_max_tokens = 16384;
              }
              {
                id = "claude-sonnet-4";
                name = "Claude Sonnet 4";
                context_window = 128000;
                default_max_tokens = 16384;
              }
              {
                id = "claude-haiku-4.5";
                name = "Claude Haiku 4.5";
                context_window = 136000;
                default_max_tokens = 16384;
              }
              {
                id = "gpt-5.4";
                name = "GPT-5.4";
                context_window = 272000;
                default_max_tokens = 16384;
              }
              {
                id = "gpt-4o";
                name = "GPT-4o";
                context_window = 64000;
                default_max_tokens = 16384;
              }
              {
                id = "gemini-2.5-pro";
                name = "Gemini 2.5 Pro";
                context_window = 128000;
                default_max_tokens = 16384;
              }
            ];
          };
        };
        models = {
          default = {
            provider = "copilot";
            model = "claude-opus-4.6-1m";
          };
        };
      };
    };
  };
}
