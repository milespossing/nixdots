---
name: pi-startup-profiling
description: Use when the user wants to profile pi startup time, compare wrapped pi vs core pi, identify slow pi extensions, or reproduce the working PI_TIMING/PI_STARTUP_BENCHMARK workflow. Includes the TTY/script workaround and known failed approaches to avoid.
metadata:
  author: miles
  repo: ~/.config/nixos
  version: "1.0"
---

# Profile pi startup time

Use pi's built-in startup instrumentation and a pseudo-TTY to measure
interactive startup. The usual failure mode is accidentally running pi in
non-interactive/print mode, which either skips the path being profiled or
makes `PI_STARTUP_BENCHMARK` error.

## Quick answer: the working command

Run pi under `script` so stdin/stdout look like a TTY, set both timing env
vars, and stop after interactive initialization:

```bash
timeout 20s script -qefc \
  'env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --approve --no-session' \
  /dev/null 2>&1 \
  | sed -n '/--- Startup Timings ---/,/------------------------/p'
```

Important flags/env:

- `PI_TIMING=1` prints phase timings.
- `PI_STARTUP_BENCHMARK=1` initializes interactive mode, prints timings,
  then exits instead of waiting for input.
- `PI_OFFLINE=1` removes startup network noise. It does **not** bypass
  extension loading.
- `script -qefc ... /dev/null` provides the pseudo-TTY required for pi to
  choose interactive mode inside this agent harness.
- `--approve --no-session` avoids project trust prompts and session IO
  noise.

## What not to do

Avoid these false starts:

- Do **not** run `PI_STARTUP_BENCHMARK=1 pi ...` directly from the agent
  harness. Without a TTY, pi resolves to non-interactive mode and prints:
  `PI_STARTUP_BENCHMARK only supports interactive mode`.
- Do **not** use `pi -p`, `--mode json`, `--help`, or `--version` as a
  proxy for interactive startup. They do not exercise the same UI/runtime
  path.
- Do **not** set only `PI_TIMING=1` unless you are prepared to manually
  quit/timeout pi. Without `PI_STARTUP_BENCHMARK`, interactive pi keeps
  running after startup.
- Do **not** profile one extension by invoking wrapped `pi --extension X`.
  The wrapped binary still loads every bundled extension first. Use the
  underlying core pi binary for isolation.
- Do **not** treat async version/package update checks as the main startup
  path. With `PI_STARTUP_BENCHMARK`, timing stops after `interactiveMode.init`;
  use `PI_OFFLINE=1` anyway for stable measurements.

## Procedure

### 1. Identify wrapped and core pi

The installed `pi` in this flake is usually a wrapper that appends many
`--extension <store-path>` flags. Find the wrapper and the underlying core
binary:

```bash
WRAPPED=$(realpath "$(command -v pi)")
printf 'wrapped=%s\n' "$WRAPPED"

# In this repo's wrapper, the first pi-coding-agent bin/pi in the exec line
# is the core pi binary that should be used for extension-isolation runs.
CORE=$(grep -o '/nix/store/[^ ]*-pi-coding-agent-[^ ]*/bin/pi' "$WRAPPED" | head -1)
: "${CORE:=$WRAPPED}"
printf 'core=%s\n' "$CORE"
```

If unsure, read the wrapper file. The wrapper should have an `exec .../bin/pi
--extension ... "$@"` line. The core binary is the target before the
extension flags.

### 2. Capture baseline startup timings

Run several samples for the current wrapped pi:

```bash
for i in 1 2 3; do
  echo "=== wrapped pi run $i ==="
  timeout 20s script -qefc \
    'env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --approve --no-session' \
    /dev/null 2>&1 \
    | sed -n '/--- Startup Timings ---/,/------------------------/p'
done
```

Then compare to core pi with no wrapper extensions:

```bash
for i in 1 2 3; do
  echo "=== core pi run $i ==="
  timeout 20s script -qefc \
    "env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 '$CORE' --approve --no-session" \
    /dev/null 2>&1 \
    | sed -n '/--- Startup Timings ---/,/------------------------/p'
done
```

Interpretation:

- The key phase is usually `createAgentSessionRuntime`; it includes
  settings/resource loading, extension loading, model registry setup, and
  agent session construction.
- `interactiveMode.init` is only the terminal UI initialization after the
  runtime exists.
- If wrapped pi is seconds slower than core pi, suspect extensions first.

### 3. Rank bundled extensions individually

Extract extension paths from the wrapper and load each one against core pi:

```bash
mapfile -t EXTS < <(grep -o -- '--extension [^ ]*' "$WRAPPED" | awk '{print $2}')

printf '%-64s %10s %10s\n' 'extension' 'runtime' 'total'
for ext in "${EXTS[@]}"; do
  out=$(timeout 30s script -qefc \
    "env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 '$CORE' --approve --no-session --extension '$ext'" \
    /dev/null 2>&1 || true)

  rt=$(printf '%s\n' "$out" | sed -n 's/.*createAgentSessionRuntime: \([0-9][0-9]*\)ms.*/\1/p' | tail -1)
  total=$(printf '%s\n' "$out" | sed -n 's/.*TOTAL: \([0-9][0-9]*\)ms.*/\1/p' | tail -1)
  printf '%-64s %10s %10s\n' "${ext##*/}" "${rt:-ERR}" "${total:-ERR}"
done
```

Repeat any suspicious extension 3+ times. Single-extension costs are not
perfectly additive because dependencies can overlap, but a multi-second
single-extension result is actionable.

### 4. Confirm by subtracting extensions

When a likely slow extension is found, compare the full explicit extension
set to the set with that extension removed. Build the command from the
extracted paths, then omit one candidate.

Skeleton:

```bash
run_set() {
  local name=$1; shift
  local extargs=""
  for ext in "$@"; do extargs="$extargs --extension '$ext'"; done

  for i in 1 2 3; do
    out=$(timeout 45s script -qefc \
      "env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 '$CORE' --approve --no-session $extargs" \
      /dev/null 2>&1 || true)
    printf '%s run %s: ' "$name" "$i"
    printf '%s\n' "$out" \
      | sed -n 's/.*createAgentSessionRuntime: \([0-9][0-9]*\)ms.*/runtime=\1ms/p; s/.*TOTAL: \([0-9][0-9]*\)ms.*/total=\1ms/p' \
      | paste -sd' ' -
  done
}

run_set all "${EXTS[@]}"
# Example omit by filtering a known path fragment:
mapfile -t WITHOUT_CANDIDATE < <(printf '%s\n' "${EXTS[@]}" | grep -v 'pi-azure-devops')
run_set without-candidate "${WITHOUT_CANDIDATE[@]}"
```

### 5. Probe TypeScript source vs compiled JS entrypoints

If a slow extension is a pi package that loads `index.ts` or `src/**/*.ts`,
test whether loading compiled JS is faster. This was the key breakthrough
for `pi-azure-devops`: the package had `dist/extension/index.js`, but its
pi manifest pointed at `./index.ts`, causing jiti/TypeScript source loading
and eager imports.

For `pi-azure-devops`, create a temporary package that preserves skills and
prompts but points the extension entrypoint at compiled JS:

```bash
ADO=/nix/store/...-patimweb-pi-azure-devops-1.4.1
FAST=/tmp/pi-ado-fast-package
rm -rf "$FAST" && mkdir -p "$FAST"
cat > "$FAST/package.json" <<EOF
{
  "name": "ado-fast-probe",
  "version": "0.0.0",
  "type": "module",
  "pi": {
    "extensions": ["$ADO/dist/extension/index.js"],
    "skills": ["$ADO/skills"],
    "prompts": ["$ADO/prompts"]
  }
}
EOF

for ext in "$ADO" "$FAST"; do
  echo "=== ${ext##*/} ==="
  timeout 30s script -qefc \
    "env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 '$CORE' --approve --no-session --extension '$ext'" \
    /dev/null 2>&1 \
    | sed -n '/--- Startup Timings ---/,/------------------------/p'
done
```

If the compiled-entry probe is much faster, fix the Nix package to expose
compiled JS at runtime instead of TypeScript source.

## Reporting format

Summarize results with:

1. the exact command/env used;
2. whether measurements are built-in timer totals or wall-clock;
3. core pi vs wrapped pi;
4. top slow extensions by `createAgentSessionRuntime` average;
5. subtractive confirmation for the top suspect;
6. concrete remediation, e.g. remove an extension from the wrapper or patch
   its package manifest to load `dist/*.js`.

## Project-specific notes from the first investigation

In this repo, the installed wrapped pi was discovered at
`/etc/profiles/per-user/miles/bin/pi`, resolving to a Nix store wrapper
that execs the core `pi-coding-agent` binary with many `--extension` flags.
The first successful profiling used:

```bash
timeout 20s script -qefc 'env PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --approve --no-session' /dev/null
```

The major bottleneck was `pi-azure-devops`. The reason was not network IO;
`PI_OFFLINE=1` still showed the delay. The package loaded TypeScript source
via `index.ts -> src/extension/index.ts`, which eagerly imported many tool
modules and `azure-devops-node-api`. A temporary package manifest that used
`dist/extension/index.js` instead of `index.ts` reduced the Azure DevOps
extension startup cost dramatically and cut the full bundle startup from
multi-second to roughly ~1.2s in the probe.
