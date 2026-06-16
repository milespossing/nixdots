/**
 * agent-browser-edge-bridge
 *
 * Opinionated pi extension: when the LLM calls the `agent_browser` tool from
 * inside WSL, transparently make sure the underlying agent-browser session
 * is attached over CDP to Microsoft Edge running on the Windows host
 * instead of trying (and failing) to launch a Linux Chromium.
 *
 * Mechanism
 * ---------
 * Hook the `tool_call` event for `agent_browser`. On the FIRST call:
 *  1. Obtain a working CDP URL for the Windows-side Edge bridge:
 *     a. FAST PATH: if a previous pi session left a CDP URL behind in
 *        $XDG_RUNTIME_DIR/pi-agent-browser-cdp-url, probe it with a short
 *        `fetch` to `/json/version`. If it answers, reuse it -- Edge and
 *        the forwarder are still up from the previous session.
 *     b. SLOW PATH: run the bundled `scripts/bootstrap.sh` (idempotent)
 *        which launches Edge on Windows with `--remote-debugging-port=9222`
 *        and a PowerShell TCP forwarder exposing `http://<win-host>:9223`.
 *  2. Mutate `event.input.args` to PREPEND `--cdp <bridge-url>` and force
 *     `event.input.sessionMode = "fresh"`. `pi-agent-browser-native`
 *     treats `--cdp` as a launch-scoped flag and `fresh` to apply it -- the
 *     resulting managed session attaches to the bridge instead of launching
 *     a local Chrome.
 *  3. Persist the resolved URL to the runtime-dir cache so the next pi
 *     session can use the FAST PATH and skip the bootstrap shellout.
 * On every SUBSEQUENT call in the same pi process, leave args/mode alone.
 * `pi-agent-browser-native`'s managed-session model reuses the CDP-attached
 * upstream session for the rest of the pi process's life.
 *
 * Failure backoff
 * ---------------
 * If `ensureBridge` fails (bootstrap.sh exits non-zero, or the cached URL
 * probe + a fresh bootstrap both failed), we enter a FAILURE_BACKOFF_MS
 * cooldown during which further `agent_browser` calls fail fast with a
 * cooldown message instead of re-running bootstrap on every tool call.
 * `/ab-edge-reset` clears the cooldown explicitly.
 *
 * Why not pre-`agent-browser connect`?
 * ------------------------------------
 * Earlier draft did exactly that, but `pi-agent-browser-native`'s
 * `runAgentBrowserProcess` always overrides `AGENT_BROWSER_SOCKET_DIR` to
 * its own per-uid value regardless of the caller's `process.env` -- our
 * pre-connect went to a DIFFERENT daemon than the tool's spawns. Verified
 * by inspecting `dist/.../lib/process.js` and reproducing the daemon split
 * with `agent-browser get cdp-url` against both socket dirs. Injecting the
 * flag into the tool's own args sidesteps the daemon question entirely.
 *
 * Per-session isolation
 * ---------------------
 * `pi-agent-browser-native` already names its daemon socket per
 * implicit-session (see `createImplicitSessionName` in runtime.js); each
 * pi process gets its own `.sock` inside `/tmp/piab-<uid>/`. No additional
 * isolation work needed in this extension.
 *
 * Not WSL-gated internally; the Nix flake decides which hosts load it.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// Resolve the bundled scripts dir relative to this source file at runtime.
const here =
  (import.meta as { dirname?: string }).dirname ??
  dirname(fileURLToPath(import.meta.url));
const BOOTSTRAP_SH = resolve(here, "..", "scripts", "bootstrap.sh");

const STATUS_KEY = "ab-edge-bridge";
const BOOTSTRAP_TIMEOUT_MS = 60_000;
// Quick HTTP probe to validate a cached CDP endpoint. Should be well
// under a second on a healthy bridge.
const PROBE_TIMEOUT_MS = 3_000;
// After a bootstrap failure, fail-fast for this long instead of trying
// to re-launch Edge / re-deploy the forwarder on every single tool call.
// `/ab-edge-reset` clears the cooldown explicitly.
const FAILURE_BACKOFF_MS = 30_000;

// Cross-pi-session cache for the resolved CDP URL. Lives under
// $XDG_RUNTIME_DIR so it's wiped on reboot (which is what we want --
// the Windows-host IP can change after a Windows restart). Falls back
// to /tmp on systems without XDG_RUNTIME_DIR.
const CACHE_FILE = (() => {
  const runtime = process.env.XDG_RUNTIME_DIR;
  if (runtime) return resolve(runtime, "pi-agent-browser-cdp-url");
  const uid =
    typeof process.getuid === "function" ? String(process.getuid()) : "user";
  return resolve(tmpdir(), `pi-agent-browser-cdp-url-${uid}`);
})();

interface ExecLike {
  stdout: string;
  stderr: string;
  code: number;
  killed?: boolean;
}

interface AgentBrowserToolInput {
  args?: string[];
  sessionMode?: "auto" | "fresh";
  [key: string]: unknown;
}

function lastNonEmptyLine(s: string): string {
  const lines = s.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
  return lines[lines.length - 1] ?? "";
}

function formatExecFailure(label: string, result: ExecLike): string {
  const tail = (result.stderr || result.stdout || "")
    .trim()
    .split(/\r?\n/)
    .slice(-10)
    .join("\n");
  return `${label} failed (exit ${result.code})${tail ? `:\n${tail}` : ""}`;
}

function formatBootstrapFailure(err: unknown): string {
  const msg = err instanceof Error ? err.message : String(err);
  return [
    "agent_browser Edge bridge unavailable. The tool was not executed.",
    "",
    msg,
    "",
    "What to try next:",
    "  • Run /ab-edge-reset to drop cached state and re-bootstrap from scratch.",
    "  • From WSL, probe the bridge directly:",
    "      curl -sf http://$(ip route show default | awk '/default/ {print $3}'):9223/json/version",
    "  • On Windows, confirm Edge is running under the 'User Data - CDP' profile",
    "    and that the PowerShell TCP forwarder is listening on port 9223",
    "    (Get-NetTCPConnection -LocalPort 9223 -State Listen).",
    "  • If Edge or the forwarder is wedged, close the 'Edge - CDP' window",
    "    (and any stuck powershell.exe forwarder) on Windows and retry.",
  ].join("\n");
}

function formatBackoffMessage(remainingMs: number): string {
  const remainingS = Math.max(1, Math.ceil(remainingMs / 1000));
  return [
    `agent_browser Edge bridge bootstrap failed recently; cooling down for ~${remainingS}s.`,
    "",
    "Run /ab-edge-reset to bypass the cooldown and retry immediately, or wait",
    "and the next agent_browser call will try again automatically.",
  ].join("\n");
}

async function readCachedUrl(): Promise<string | null> {
  try {
    const data = await readFile(CACHE_FILE, "utf8");
    const url = data.trim();
    return /^https?:\/\//.test(url) ? url : null;
  } catch {
    return null;
  }
}

async function writeCachedUrl(url: string): Promise<void> {
  try {
    await writeFile(CACHE_FILE, url + "\n", "utf8");
  } catch {
    // Best-effort cache; non-fatal if the runtime dir is read-only.
  }
}

async function clearCachedUrl(): Promise<void> {
  await rm(CACHE_FILE, { force: true }).catch(() => undefined);
}

async function probeCdp(url: string): Promise<boolean> {
  // Node 18+ ships a global `fetch`; the pi runtime is Node 20+.
  try {
    const res = await fetch(`${url}/json/version`, {
      signal: AbortSignal.timeout(PROBE_TIMEOUT_MS),
    });
    return res.ok;
  } catch {
    return false;
  }
}

export default function (pi: ExtensionAPI) {
  // Cached bootstrap promise. Cleared on failure or /ab-edge-reset.
  let bridge: Promise<string> | null = null;
  let bridgeCdpUrl: string | null = null;
  let lastFailureAt: number | null = null;
  // Whether the upcoming/current tool call should carry --cdp + fresh.
  // Toggled true synchronously (before await) to make the parallel-tool
  // case deterministic: only the first handler invocation to observe
  // `true` becomes the injector; all others run untouched.
  let needsInjection = true;

  // Fast path: if a previous pi session left a CDP URL behind and it's
  // still answering, just reuse it. Skips the bootstrap.sh shellout
  // entirely (which costs ~1-3s of forwarder/port probing).
  async function tryCachedUrl(ctx: ExtensionContext): Promise<string | null> {
    const cached = await readCachedUrl();
    if (!cached) return null;
    if (!(await probeCdp(cached))) return null;
    ctx.ui.setStatus(STATUS_KEY, `Edge bridge: reusing cached ${cached}`);
    return cached;
  }

  // Slow path: idempotent launch of Edge + the PowerShell forwarder on
  // Windows, plus a sanity-probe round-trip. Returns the resolved URL.
  async function runBootstrap(ctx: ExtensionContext): Promise<string> {
    ctx.ui.setStatus(STATUS_KEY, "Edge bridge: bootstrapping…");
    const boot = (await pi.exec("bash", [BOOTSTRAP_SH], {
      timeout: BOOTSTRAP_TIMEOUT_MS,
    })) as ExecLike;
    if (boot.code !== 0) {
      throw new Error(formatExecFailure(`bootstrap.sh (${BOOTSTRAP_SH})`, boot));
    }
    const cdpUrl = lastNonEmptyLine(boot.stdout);
    if (!/^https?:\/\//.test(cdpUrl)) {
      throw new Error(
        `bootstrap.sh did not emit a CDP URL on its last stdout line.\n` +
          `Last line: ${JSON.stringify(cdpUrl)}\n` +
          `Full stdout:\n${boot.stdout}`,
      );
    }
    return cdpUrl;
  }

  function ensureBridge(ctx: ExtensionContext): Promise<string> {
    if (bridge) return bridge;

    // Fail-fast inside the cooldown window so repeated tool calls don't
    // thrash Windows when the bridge is wedged.
    if (lastFailureAt !== null) {
      const elapsed = Date.now() - lastFailureAt;
      if (elapsed < FAILURE_BACKOFF_MS) {
        return Promise.reject(
          new Error(formatBackoffMessage(FAILURE_BACKOFF_MS - elapsed)),
        );
      }
      lastFailureAt = null;
    }

    bridge = (async () => {
      const cached = await tryCachedUrl(ctx);
      if (cached) return cached;
      return runBootstrap(ctx);
    })().then(
      (url) => {
        bridgeCdpUrl = url;
        lastFailureAt = null;
        ctx.ui.setStatus(STATUS_KEY, `Edge bridge: ${url}`);
        // Persist for the next pi session. Best-effort.
        void writeCachedUrl(url);
        return url;
      },
      (err) => {
        bridge = null;
        bridgeCdpUrl = null;
        lastFailureAt = Date.now();
        // Forget the cached URL so the next attempt (after cooldown)
        // starts from a full bootstrap rather than re-probing a stale URL.
        void clearCachedUrl();
        ctx.ui.setStatus(STATUS_KEY, "Edge bridge: failed");
        throw err;
      },
    );
    return bridge;
  }

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "agent_browser") return;

    // Synchronous check-and-set so only one handler invocation injects,
    // even under parallel tool execution where multiple agent_browser
    // calls fire concurrently.
    const shouldInject = needsInjection;
    if (shouldInject) needsInjection = false;

    let cdpUrl: string;
    try {
      cdpUrl = await ensureBridge(ctx);
    } catch (err) {
      if (shouldInject) needsInjection = true; // roll back so the next call retries
      return {
        block: true,
        reason: formatBootstrapFailure(err),
      };
    }

    if (!shouldInject) return; // bridge already set up; leave args alone

    // Prepend --cdp <url> and force fresh so pi-agent-browser-native's
    // managed-session model launches a NEW upstream session attached to
    // the bridge. Subsequent calls in auto mode reuse this session.
    const input = event.input as AgentBrowserToolInput;
    input.args = ["--cdp", cdpUrl, ...(Array.isArray(input.args) ? input.args : [])];
    input.sessionMode = "fresh";
  });

  pi.registerCommand("ab-edge-status", {
    description: "Show the agent-browser Edge bridge status",
    handler: async (_args, ctx) => {
      if (bridgeCdpUrl) {
        const note = needsInjection
          ? " (next agent_browser call will inject --cdp + fresh)"
          : "";
        ctx.ui.notify(`Edge bridge ready at ${bridgeCdpUrl}${note}`, "info");
        return;
      }
      if (bridge) {
        ctx.ui.notify("Edge bridge: bootstrapping…", "info");
        return;
      }
      if (lastFailureAt !== null) {
        const remaining = FAILURE_BACKOFF_MS - (Date.now() - lastFailureAt);
        if (remaining > 0) {
          ctx.ui.notify(
            `Edge bridge: failed; cooling down for ~${Math.ceil(remaining / 1000)}s. ` +
              `Use /ab-edge-reset to retry now.`,
            "warning",
          );
          return;
        }
      }
      const cached = await readCachedUrl();
      if (cached) {
        ctx.ui.notify(
          `Edge bridge: idle. Cached CDP URL from previous session: ${cached} ` +
            `(will probe before reuse on next agent_browser call).`,
          "info",
        );
        return;
      }
      ctx.ui.notify(
        "Edge bridge: idle (no agent_browser call has been made yet).",
        "info",
      );
    },
  });

  pi.registerCommand("ab-edge-reset", {
    description:
      "Force a fresh Edge-bridge bootstrap + CDP attach on the next agent_browser call",
    handler: async (_args, ctx) => {
      bridge = null;
      bridgeCdpUrl = null;
      lastFailureAt = null;
      needsInjection = true;
      await clearCachedUrl();
      ctx.ui.setStatus(STATUS_KEY, "Edge bridge: reset");
      ctx.ui.notify(
        "Edge bridge reset (in-memory state, cached URL, and cooldown cleared). " +
          "Next agent_browser call will re-bootstrap and re-attach via CDP.",
        "info",
      );
    },
  });
}
