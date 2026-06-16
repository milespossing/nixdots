{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  pi = cfg.pi;

  hasRules = cfg.rules.global != "";

  # Layer per-host runtime packages on top of the baseline wired into
  # `modules/pi/pi.nix`. `.wrap` re-evaluates the wrapper module with
  # the original config + this extra module, so we don't lose the
  # defaults (jq, gh, lazygit, ...). `runtimePkgs` is the public
  # nix-wrapper-modules option for prepending to the wrapped binary's
  # PATH.
  wrapped =
    if pi.extraPackages == [ ] && pi.extensions == [ ] then
      pkgs.pi-coding-agent
    else
      pkgs.pi-coding-agent.wrap {
        runtimePkgs = pi.extraPackages;
        extensions = pi.extensions;
      };
in
{
  config = lib.mkIf pi.enable {
    home.packages = [ wrapped ];

    # Pi auto-loads ~/.pi/agent/AGENTS.md as global context. Mirror
    # the shared rules there so all agents share one source of truth.
    # Pi never writes to context files, so a /nix/store symlink is
    # safe. settings.json is left alone -- pi rewrites it via `/set`.
    home.file = lib.mkIf hasRules {
      ".pi/agent/AGENTS.md".text = cfg.rules.global;
    };
  };
}
