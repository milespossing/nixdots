# agent-browser-edge-bridge

Pi extension. On WSL, transparently routes the `agent_browser` tool through
Microsoft Edge running on the Windows host (via Chrome DevTools Protocol)
instead of trying to launch a Linux Chromium that doesn't exist in WSL.

Layers on top of `pi-agent-browser-native` (which registers the
`agent_browser` tool). Loading order is enforced by listing this extension
*after* `pi-agent-browser-native` in the pi extension list.

## Behavior

- Hooks `tool_call` for `agent_browser`. On the **first** call in a pi
  process:
  1. Resolves a working CDP URL for the Windows-side Edge bridge:
     - **Fast path:** if a previous pi session left a CDP URL in
       `$XDG_RUNTIME_DIR/pi-agent-browser-cdp-url`, the extension
       probes it with a short `fetch` to `/json/version`. If it answers,
       the URL is reused and the bootstrap shellout is skipped
       entirely (Edge + forwarder are still up from before).
     - **Slow path:** runs the bundled `scripts/bootstrap.sh`
       (idempotent). It launches Edge on Windows with
       `--remote-debugging-port=9222` and a dedicated `User Data - CDP`
       profile, plus a PowerShell TCP forwarder
       (`scripts/cdp_forwarder.ps1`, `Add-Type` + .NET async, no Python)
       exposing CDP at `http://<win-host>:9223`.
  2. Mutates `event.input.args` to prepend `--cdp <bridge-url>` and
     forces `event.input.sessionMode = "fresh"`. `pi-agent-browser-native`
     treats `--cdp` as a launch-scoped flag and `fresh` makes it apply --
     the resulting managed session attaches to the bridge instead of
     launching a local Chrome.
  3. Persists the resolved URL back to the runtime-dir cache so the
     next pi session can use the fast path.
- On every **subsequent** call in the same pi process: leaves args/mode
  alone. `pi-agent-browser-native`'s managed-session model reuses the
  CDP-attached upstream session for the rest of the pi process's life.
- On bootstrap failure: the tool call is **blocked** with a structured
  "what to try next" reason surfaced to the LLM (probe commands,
  Windows-side checks, `/ab-edge-reset` hint), the "needs injection"
  flag is rolled back so the next call retries, and the extension
  enters a 30 s **failure-backoff window** during which further
  `agent_browser` calls fail fast with a cooldown message instead of
  re-running bootstrap. `/ab-edge-reset` clears the cooldown.

## Per-session isolation

`pi-agent-browser-native` already names its daemon socket per
implicit-session (see `createImplicitSessionName` in its `runtime.js`);
each pi process gets its own `.sock` inside `/tmp/piab-<uid>/`. No
additional isolation work happens in this extension.

## One-time Windows sign-in

The first time you visit an AAD-protected site, the dedicated Edge
profile (`User Data - CDP`) will hit the Microsoft sign-in wall. Sign
in once in the visible Edge window on Windows; cookies persist in that
profile across reboots and all future pi sessions.

## Files

- `src/index.ts` --- the pi extension.
- `scripts/bootstrap.sh` --- launches Edge + the PowerShell forwarder.
  Idempotent. Prints the CDP URL on the last line of stdout.
- `scripts/cdp_forwarder.ps1` --- Windows-side TCP relay. Compiles a tiny
  C# class via `Add-Type` for async I/O on the .NET thread pool. No
  external runtime; works with stock `powershell.exe` (5.1+).

## Slash commands

- `/ab-edge-status` --- shows whether the bridge has been bootstrapped
  (and whether the next `agent_browser` call will inject `--cdp +
  fresh`), is currently bootstrapping, is inside a failure-cooldown
  window (with remaining seconds), or just has a cached URL from a
  previous session waiting to be probed.
- `/ab-edge-reset` --- clears the in-memory bridge state, the cross-
  session cached CDP URL, and any active cooldown, so the next
  `agent_browser` call re-bootstraps and re-attaches via CDP.

## Why not pre-`agent-browser connect`?

Earlier drafts ran `agent-browser connect <url>` from the `tool_call`
hook, but `pi-agent-browser-native`'s `runAgentBrowserProcess` always
overrides `AGENT_BROWSER_SOCKET_DIR` to its own per-uid value regardless
of the caller's `process.env`. The pre-connect went to a different daemon
than the tool's spawns. Injecting `--cdp` into the tool's own args
sidesteps the daemon question entirely.
