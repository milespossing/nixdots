{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent,
}:
# pi-base: the common pi wrapper every offered variant builds on. It
# starts from the baseline pi wrapper (runtimePkgs on PATH from
# `pi.nix`) and adds the extensions we always want available,
# regardless of host.
#
# The two offered variants -- pi-desktop (euler/laplace) and pi-wsl
# (work) -- wrap *this* package so they inherit these defaults without
# re-listing them. `basePackage.wrap` extends the existing
# nix-wrapper-modules configuration, so the baseline runtime PATH and
# the extensions below both carry through.
basePackage.wrap {
  extensions = with pkgs.piExtensions; [
    pi-copilot-discovery # live Copilot model discovery (replaces static catalog)
    rpiv-todo # live todo overlay that survives reload / compaction
    notify # native/Gotify/Telegram/ntfy notifications
    rpiv-btw # /btw slash command for side questions
    rpiv-ask-user-question # structured questionnaire for the model to ask the user
    edb-agent-steer # steer / queue / discard / edit mid-turn messages
    pi-interview # interview-mode extension
  ];
}
