{ pkgs, ... }:
# Shared pi extensions every offered variant (desktop + wsl) builds on, on top
# of the baseline. Imported alongside ./baseline.nix; the `extensions` list
# accumulates across modules.
{
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
