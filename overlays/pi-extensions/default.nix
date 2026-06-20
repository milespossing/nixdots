# Overlay: pkgs.piExtensions — pi-coding-agent extensions as Nix derivations.
#
# Each entry is a derivation whose output is a directory matching the
# pi-package layout (i.e. an unpacked npm tarball or a git checkout
# with a `package.json` `pi` manifest). The pi wrapper passes them as
# `--extension <store-path>` flags on each invocation.
#
# Add a new extension by either:
#   - calling `mkPiExtensionFromNpm { pname; version; hash; ... }` and
#     registering it in the attrset below, OR
#   - using `mkPiExtensionFromGit` (TODO) for git-based packages.
#
# To get the `hash`: `nix-prefetch-url --type sha256 <tarball-url>`
# then convert with `nix hash to-sri sha256:<hex>` (or use
# `nix store prefetch-file` which prints SRI directly).
final: prev:
let
  inherit (final) lib;

  # Derive the npm tarball URL from a scoped or unscoped package
  # name + version. Scoped packages live at
  # `https://registry.npmjs.org/@scope/name/-/name-<version>.tgz`
  # (note: no `@scope` in the tarball filename).
  npmTarballUrl =
    pname: version:
    let
      unscoped = lib.last (lib.splitString "/" pname);
    in
    "https://registry.npmjs.org/${pname}/-/${unscoped}-${version}.tgz";

  typebox_1_1_38 = final.fetchurl {
    url = npmTarballUrl "typebox" "1.1.38";
    hash = "sha512-pZ0aQPmMmXoUvSbeuWf/Hzsc+avNw/Zd6VeE8CFgkVGWyuHPJvqeJJDeJqLve+K70LvjYIoleGcoJHPT17cWoA==";
  };

  rpivConfig_1_20_0 = final.fetchurl {
    url = npmTarballUrl "@juicesharp/rpiv-config" "1.20.0";
    hash = "sha512-eu/sEBDt/+9kP40yCtlu04kRUxkQNaG1APzNIgnt5dGsualcwruedLWX9vtt0Fg4NSCAlNx5b2r9VjcWgAJirQ==";
  };

  # Build an rpiv extension that depends on @juicesharp/rpiv-config.
  # We vendor rpiv-config (and its typebox peer) by hand because the
  # rpiv package tarballs do not include package-lock.json files.
  mkRpivExtensionWithConfig =
    {
      pname,
      version,
      hash,
      meta ? { },
    }:
    let
      unscoped = lib.last (lib.splitString "/" pname);
      src = final.fetchurl {
        url = npmTarballUrl pname version;
        inherit hash;
      };
      baseMeta = {
        description = "Pi coding agent extension: ${pname}";
        homepage = "https://www.npmjs.com/package/${pname}";
        license = lib.licenses.mit;
      };
    in
    final.runCommand "pi-ext-${unscoped}-${version}"
      {
        inherit src;
        meta = baseMeta // meta;
        passthru = {
          inherit pname version;
          piExtension = true;
        };
      }
      ''
        mkdir -p $out/node_modules/@juicesharp/rpiv-config $out/node_modules/typebox
        tar -xzf $src --strip-components=1 -C $out
        tar -xzf ${rpivConfig_1_20_0} --strip-components=1 -C $out/node_modules/@juicesharp/rpiv-config
        tar -xzf ${typebox_1_1_38} --strip-components=1 -C $out/node_modules/typebox
      '';

  # Build a pi extension from an npm registry tarball.
  #
  # Args:
  #   pname        - scoped or unscoped npm package name
  #   version      - npm version string
  #   hash         - SRI hash of the .tgz tarball
  #   npmDepsHash  - if the package has runtime npm deps, set this so
  #                  buildNpmPackage installs them. Skip for dep-free
  #                  extensions (faster, simpler).
  #   meta         - merged into derivation meta
  mkPiExtensionFromNpm =
    {
      pname,
      version,
      hash,
      npmDepsHash ? null,
      meta ? { },
    }:
    let
      unscoped = lib.last (lib.splitString "/" pname);
      tarball = final.fetchurl {
        url = npmTarballUrl pname version;
        inherit hash;
      };
      baseMeta = {
        description = "Pi coding agent extension: ${pname}";
        homepage = "https://www.npmjs.com/package/${pname}";
        license = lib.licenses.mit; # most pi extensions are MIT; override per-package
      };
    in
    if npmDepsHash == null then
      # No runtime deps: skip the npm install dance entirely. Just
      # unpack the tarball into the derivation output.
      final.runCommand "pi-ext-${unscoped}-${version}"
        {
          src = tarball;
          meta = baseMeta // meta;
          passthru = {
            inherit pname version;
            piExtension = true;
          };
        }
        ''
          mkdir -p $out
          tar -xzf $src --strip-components=1 -C $out
        ''
    else
      # Has deps: let buildNpmPackage handle `npm install --omit=dev`
      # and ship the resulting node_modules alongside the package.
      final.buildNpmPackage {
        inherit pname version npmDepsHash;
        src = tarball;
        # Skip build/test scripts -- pi loads .ts files directly via
        # jiti, so there's nothing to compile.
        dontNpmBuild = true;
        dontNpmCheck = true;
        # Default install phase wants `dist/` etc.; we want the whole
        # package directory (including node_modules) preserved.
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out/
          runHook postInstall
        '';
        meta = baseMeta // meta;
        passthru = {
          piExtension = true;
        };
      };
in
{
  piExtensions = {
    # Expose the builders so downstream code can add ad-hoc extensions
    # without modifying this overlay (e.g. a host-local extension).
    inherit mkPiExtensionFromNpm npmTarballUrl;

    # --- Registry ---------------------------------------------------

    # @agnishc/edb-agent-steer — intercepts mid-turn messages with a
    # steer / queue / discard / edit prompt.
    # https://github.com/agnishcc/pi-extention-monorepo/tree/main/packages/edb-agent-steer
    edb-agent-steer = mkPiExtensionFromNpm {
      pname = "@agnishc/edb-agent-steer";
      version = "0.15.1";
      hash = "sha512-ozLAic/BdjFCAR9COVxW0NfJKwz3W1MwBzf2AIcKzoMI6P4kSSMxh1ymqAAE9kyt74sl9hoHvyhZrzMuLipd5Q==";
    };

    # @lumendigitaldev/pi-wsl-images — Alt+V image paste from the
    # Windows clipboard. Most useful on WSL hosts where pi can't see
    # X11/Wayland clipboards directly.
    # https://github.com/lumendigitaldev/pi-wsl-images
    pi-wsl-images = mkPiExtensionFromNpm {
      pname = "@lumendigitaldev/pi-wsl-images";
      version = "1.0.1";
      # npm-published integrity: sha512-... (copy from the registry's
      # `dist.integrity` field, which is already in SRI format).
      hash = "sha512-qiE+LW/iKOm4p3OYWa707qwHGCwKSEoLVFXhYy5IVwNAp9uX8l4k2jo01xBaMLwJEbTyIcCx2MN62TsCCpg1Eg==";
      meta.platforms = lib.platforms.linux; # WSL-specific
    };

    # @pi-unipi/notify — cross-platform notification module for pi:
    # native desktop notifications plus Gotify, Telegram, and ntfy.
    # https://github.com/Neuron-Mr-White/UniPi/tree/main/packages/notify
    notify =
      let
        version = "2.0.15";
        src = final.fetchurl {
          url = npmTarballUrl "@pi-unipi/notify" version;
          hash = "sha512-e6Mul0LDNP/3/J35PDBE8xA1sWG8Ki2emogexm2ZMTfKPUV8tbSpYx0b57iFlC1v2VI0KJh0DaDQBm8gSwMcfg==";
        };

        # @pi-unipi/notify ships without package-lock.json. Vendor the
        # small runtime tree manually so we can omit peer deps that are
        # already supplied by pi (or are type-only) and avoid pulling an
        # older pi-coding-agent into the extension output.
        core = final.fetchurl {
          url = npmTarballUrl "@pi-unipi/core" "2.0.13";
          hash = "sha512-U0tP0pQSwwUVZRP1Ox/0KJNxkeQShUMvL6EdUnXn/oAeh5Pu+91X90SFjP2MOnppEjIMLITGoJcSYyh6/JxelQ==";
        };
        piTui = final.fetchurl {
          url = npmTarballUrl "@earendil-works/pi-tui" "0.79.4";
          hash = "sha512-/ZhfFiHSBMH7AbDrBQIN+UWlJnl9tSEpLYICRGGMzmNfyCqX+30NYacIhyOEaD8R5rS6wJZysAOPU0yNwigbXw==";
        };
        getEastAsianWidth = final.fetchurl {
          url = npmTarballUrl "get-east-asian-width" "1.6.0";
          hash = "sha512-QRbvDIbx6YklUe6RxeTeleMR0yv3cYH6PsPZHcnVn7xv7zO1BHN8r0XETu8n6Ye3Q+ahtSarc3WgtNWmehIBfA==";
        };
        growly = final.fetchurl {
          url = npmTarballUrl "growly" "1.3.0";
          hash = "sha512-+xGQY0YyAWCnqy7Cd++hc2JqMYzlm0dG30Jd0beaA64sROr8C4nt8Yc9V5Ro3avlSUDTN0ulqP/VBKi1/lLygw==";
        };
        isDocker = final.fetchurl {
          url = npmTarballUrl "is-docker" "2.2.1";
          hash = "sha512-F+i2BKsFrH66iaUFc0woD8sLy8getkwTwtOBjvs56Cx4CgJDeKQeqfz8wAYiSb8JOprWhHH5p77PbmYCvvUuXQ==";
        };
        isWsl = final.fetchurl {
          url = npmTarballUrl "is-wsl" "2.2.0";
          hash = "sha512-fKzAra0rGJUUBwGBgNkHZuToZcn+TtXHpeCgmkMJMMYx1sQDYaCSyjJBSCa2nH1DGm7s3n1oBnohoVTBaN7Lww==";
        };
        isexe = final.fetchurl {
          url = npmTarballUrl "isexe" "2.0.0";
          hash = "sha512-RHxMLp9lnKHGHRng9QFhRCMbYAcVpn69smSGcq3f36xjgVVWThj4qqLbTLlq7Ssj8B+fIQ1EuCEGI2lKsyQeIw==";
        };
        marked = final.fetchurl {
          url = npmTarballUrl "marked" "15.0.12";
          hash = "sha512-8dD6FusOQSrpv9Z1rdNMdlSgQOIP880DHqnohobOmYLElGEqAL/JvxvuxZO16r4HtjTlfPRDC1hbvxC9dPN2nA==";
        };
        nodeNotifier = final.fetchurl {
          url = npmTarballUrl "node-notifier" "10.0.1";
          hash = "sha512-YX7TSyDukOZ0g+gmzjB6abKu+hTGvO8+8+gIFDsRCU2t8fLV/P2unmt+LGFaIa4y64aX98Qksa97rgz4vMNeLQ==";
        };
        semver = final.fetchurl {
          url = npmTarballUrl "semver" "7.8.4";
          hash = "sha512-rUCObTnP32Q08R2uuIrt7r9PlEonuTmtuXYcW6s5kjdlj3xbnwe+21yXptAUYcMAABLkYYTtnmzb3w3EDZfueA==";
        };
        shellwords = final.fetchurl {
          url = npmTarballUrl "shellwords" "0.1.1";
          hash = "sha512-vFwSUfQvqybiICwZY5+DAWIPLKsWO31Q91JSKl3UYv+K5c2QRPzn0qzec6QPu1Qc9eHYItiP3NdJqNVqetYAww==";
        };
        typebox = final.fetchurl {
          url = npmTarballUrl "typebox" "1.1.38";
          hash = "sha512-pZ0aQPmMmXoUvSbeuWf/Hzsc+avNw/Zd6VeE8CFgkVGWyuHPJvqeJJDeJqLve+K70LvjYIoleGcoJHPT17cWoA==";
        };
        uuid = final.fetchurl {
          url = npmTarballUrl "uuid" "8.3.2";
          hash = "sha512-+NYs2QeMWy+GWFOEm9xnn6HCDp0l7QBD7ml8zLUmJ+93Q5NF0NocErnwkTkXVFNiX3/fpC6afS8Dhb/gz7R7eg==";
        };
        which = final.fetchurl {
          url = npmTarballUrl "which" "2.0.2";
          hash = "sha512-BLI3Tl1TW3Pvl70l3yq3Y64i+awpwXqsGBYWkkqMtnbXgrMD+yj7rhW0kuEDxzJaYXGjEW5ogapKNMEKNMjibA==";
        };
      in
      final.runCommand "pi-ext-notify-${version}"
        {
          meta = {
            description = "Pi coding agent extension: native, Gotify, Telegram, and ntfy notifications";
            homepage = "https://github.com/Neuron-Mr-White/UniPi/tree/main/packages/notify";
            license = lib.licenses.mit;
          };
          passthru = {
            pname = "@pi-unipi/notify";
            inherit version;
            piExtension = true;
          };
        }
        ''
                    unpack() {
                      mkdir -p "$1"
                      tar -xzf "$2" --strip-components=1 -C "$1"
                    }

                    unpack "$out" "${src}"
                    unpack "$out/node_modules/@pi-unipi/core" "${core}"
                    unpack "$out/node_modules/@earendil-works/pi-tui" "${piTui}"
                    unpack "$out/node_modules/get-east-asian-width" "${getEastAsianWidth}"
                    unpack "$out/node_modules/growly" "${growly}"
                    unpack "$out/node_modules/is-docker" "${isDocker}"
                    unpack "$out/node_modules/is-wsl" "${isWsl}"
                    unpack "$out/node_modules/isexe" "${isexe}"
                    unpack "$out/node_modules/marked" "${marked}"
                    unpack "$out/node_modules/node-notifier" "${nodeNotifier}"
                    unpack "$out/node_modules/semver" "${semver}"
                    unpack "$out/node_modules/shellwords" "${shellwords}"
                    unpack "$out/node_modules/typebox" "${typebox}"
                    unpack "$out/node_modules/uuid" "${uuid}"
                    unpack "$out/node_modules/which" "${which}"

                    # Local hotfix: @pi-unipi/notify 2.0.15 only registers the
                    # ask-user prompt listener when the event is enabled at
                    # session_start. If the user enables it from config/settings
                    # during a running Pi session, prompt notifications still do
                    # not fire until Pi restarts. Keep the listener installed and
                    # load the latest config when the question is actually asked.
                    substituteInPlace "$out/events.ts" \
                      --replace-fail \
                        'import { buildAskUserPromptMessage } from "./ask-user-prompt-message.js";' \
                        'import { buildAskUserPromptMessage } from "./ask-user-prompt-message.js";
          import { loadConfig } from "./settings.js";'

                    substituteInPlace "$out/events.ts" \
                      --replace-fail \
                        'if (eventKey === "agent_end") continue; // handled separately below' \
                        'if (eventKey === "agent_end" || eventKey === "ask_user_prompt") continue; // handled separately below'

                    substituteInPlace "$out/events.ts" \
                      --replace-fail \
                        '  // Listen for rpiv:ask-user:prompt from @juicesharp/rpiv-ask-user-question
            const askUserConfig = config.events["ask_user_prompt"];
            if (askUserConfig?.enabled) {
              unsubs.push(pi.events.on(ASK_USER_PROMPT_EVENT, (payload: unknown) => {
                const title = `Pi — ''${BUILTIN_EVENTS.ask_user_prompt.label}`;
                const message = buildAskUserPromptMessage(payload);
                dispatchNotification(pi, title, message, askUserConfig.platforms, "ask_user_prompt", config, cwd).catch(
                  () => {
                    // Silently ignore — background notification failure is non-blocking.
                  }
                );
              }));
            }' \
                        '  // Listen for ask-user prompts from UniPi and rpiv. This listener is
            // always installed and reloads config when the prompt is emitted so
            // enabling ask_user_prompt during a running Pi session takes effect
            // without a restart.
            const askUserHandler = (payload: unknown) => {
              const currentConfig = loadConfig();
              const askUserConfig = currentConfig.events["ask_user_prompt"];
              if (!askUserConfig?.enabled) return;

              const title = `Pi — ''${BUILTIN_EVENTS.ask_user_prompt.label}`;
              const message = buildAskUserPromptMessage(payload);
              dispatchNotification(
                pi,
                title,
                message,
                askUserConfig.platforms,
                "ask_user_prompt",
                currentConfig,
                cwd
              ).catch(() => {
                // Silently ignore — background notification failure is non-blocking.
              });
            };
            unsubs.push(pi.events.on(UNIPI_EVENTS.ASK_USER_PROMPT, askUserHandler));
            unsubs.push(pi.events.on(ASK_USER_PROMPT_EVENT, askUserHandler));'
        '';

    # @juicesharp/rpiv-btw — `/btw` slash command. Asks a one-off
    # side question to the same primary model without polluting the
    # main conversation thread.
    # https://github.com/juicesharp/rpiv-mono
    rpiv-btw = mkPiExtensionFromNpm {
      pname = "@juicesharp/rpiv-btw";
      version = "1.20.0";
      hash = "sha512-WTyCGnNm29/yn+nIQD9uqencHQpv0unnNiorS6QWOINxttNXrf5I1oi2qmxUjG+5vz0dw0jcWUyGOWWp1CG87Q==";
    };

    # @juicesharp/rpiv-ask-user-question — structured questionnaire
    # the model can use instead of guessing.
    # https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question
    rpiv-ask-user-question = mkRpivExtensionWithConfig {
      pname = "@juicesharp/rpiv-ask-user-question";
      version = "1.20.0";
      hash = "sha512-nccqKqeKoMDO9EZtAotyA/OkHBj+tl2jJBBSpP+1Ndyf7fnU592AO8Ax2Xk9VywHOYVz2X/66d/wC3oFUekV5Q==";
    };

    # @juicesharp/rpiv-todo — live todo overlay that survives /reload
    # and conversation compaction.
    # https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo
    rpiv-todo = mkRpivExtensionWithConfig {
      pname = "@juicesharp/rpiv-todo";
      version = "1.20.0";
      hash = "sha512-+tRVFrR/WVc/78UQm0+w+goAIKNyO28Lzrfr9agnOfccIkk98M0T/hnGY8z1PjYkNDnDk+BETiOYhhLqJvuNcQ==";
    };

    # @milespossing/pi-copilot-discovery — dynamic GitHub Copilot model
    # discovery for pi. Replaces pi-ai's static catalog with the live
    # /models list from your Copilot tenant.
    # https://github.com/milespossing/pi-copilot-discovery
    pi-copilot-discovery = mkPiExtensionFromNpm {
      pname = "@milespossing/pi-copilot-discovery";
      version = "0.3.0";
      hash = "sha256-M2gH4kffX+juLvILbcaqFF+shus1rWpSeh37cxz1VDk=";
    };

    # pi-interview — interview-mode extension for pi. Ships no
    # package-lock.json, so buildNpmPackage can't vendor its one
    # runtime dep (typebox, itself dependency-free). Unpack the
    # tarball and drop typebox into node_modules by hand instead.
    # https://www.npmjs.com/package/pi-interview
    pi-interview =
      let
        src = final.fetchurl {
          url = npmTarballUrl "pi-interview" "0.8.7";
          hash = "sha512-25Ti4JodqajFmoBBZ8E/45eIf6kdD0gPNcDY2Lw+JwclTdNo09TpCjIjPOHdMoMKzFk3oX0I7QjFScsiCiBdHA==";
        };
        typebox = final.fetchurl {
          url = npmTarballUrl "typebox" "1.2.14";
          hash = "sha512-/ogVtZUOjV69aeVvrTCmBtDNDfvXPPi28rkrQlID+bhz1dEJ9YkcnoSqCYaPIqiNifMVuTycZlZx5X82734s7w==";
        };
      in
      final.runCommand "pi-ext-pi-interview-0.8.7"
        {
          meta = {
            description = "Pi coding agent extension: pi-interview";
            homepage = "https://www.npmjs.com/package/pi-interview";
            license = lib.licenses.mit;
          };
          passthru = {
            pname = "pi-interview";
            version = "0.8.7";
            piExtension = true;
          };
        }
        ''
          mkdir -p $out/node_modules/typebox
          tar -xzf ${src} --strip-components=1 -C $out
          tar -xzf ${typebox} --strip-components=1 -C $out/node_modules/typebox
        '';

    # pi-agent-browser-native — exposes the `agent-browser` CLI to pi
    # as a native tool for browser automation. Requires
    # `agent-browser` on PATH (already added to the wrapper baseline
    # in wrappers/pi/pi.nix).
    # https://github.com/fitchmultz/pi-agent-browser-native
    pi-agent-browser-native = mkPiExtensionFromNpm {
      pname = "pi-agent-browser-native";
      version = "0.2.52";
      hash = "sha512-IcL36M00v/I/iQY7+8F2dIvsmpEjRsnuGnXQLnkEtSVqWkxy39+UDTAP9lYfnt5x+YYUIJXbp1qIDaLqQY/DZQ==";
    };

    # @patimweb/pi-azure-devops — Azure DevOps integration for pi:
    # work items, boards, repos, pull requests, pipelines, and test plans.
    # https://github.com/Smotherer007/pi-azure-devops
    pi-azure-devops =
      let
        version = "1.4.1";
        src = final.fetchurl {
          url = npmTarballUrl "@patimweb/pi-azure-devops" version;
          hash = "sha512-X5AnA8prSXwTpDkiPVitmrYpbjPxA44h82/lHaAbkin+ep0u8XBpOQJBXKyzyw9dDSPBsVohRLLtlZpIPwleIg==";
        };
        packageLock = final.fetchurl {
          url = "https://raw.githubusercontent.com/Smotherer007/pi-azure-devops/v${version}/package-lock.json";
          hash = "sha256-ZDeWHwAyhUMggEzbi8P1jjp/bHoAY4AFNn69HLm4tfA=";
        };
        typebox = final.fetchurl {
          url = npmTarballUrl "typebox" "1.1.38";
          hash = "sha512-pZ0aQPmMmXoUvSbeuWf/Hzsc+avNw/Zd6VeE8CFgkVGWyuHPJvqeJJDeJqLve+K70LvjYIoleGcoJHPT17cWoA==";
        };
      in
      final.buildNpmPackage {
        pname = "@patimweb/pi-azure-devops";
        inherit version src;
        npmDepsHash = "sha256-8Sr+XVSXvwV00Q/3UsJ3CcYO73/RBFMS5zXJDMZAawk=";

        postPatch = ''
          cp ${packageLock} package-lock.json
        '';

        # The upstream lock includes peer/dev dependencies (including an
        # older pi-coding-agent used only for local typechecking). Runtime
        # only needs azure-devops-node-api plus typebox, which we add below.
        npmInstallFlags = [
          "--omit=dev"
          "--omit=peer"
        ];
        dontNpmBuild = true;
        dontNpmCheck = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out/
          rm -f $out/package-lock.json $out/node_modules/.package-lock.json
          rm -rf $out/node_modules/@earendil-works
          mkdir -p $out/node_modules/typebox
          tar -xzf ${typebox} --strip-components=1 -C $out/node_modules/typebox
          runHook postInstall
        '';
        meta = {
          description = "Pi coding agent extension: Azure DevOps work items, repos, PRs, pipelines, and test plans";
          homepage = "https://github.com/Smotherer007/pi-azure-devops";
          license = lib.licenses.mit;
        };
        passthru = {
          pname = "@patimweb/pi-azure-devops";
          inherit version;
          piExtension = true;
        };
      };

    # pi-web-access — web search, URL fetching, GitHub repo cloning,
    # PDF extraction, YouTube understanding, and local video analysis.
    # https://github.com/nicobailon/pi-web-access
    pi-web-access =
      let
        version = "0.10.7";
        src = final.fetchurl {
          url = npmTarballUrl "pi-web-access" version;
          hash = "sha512-HbRN2dMGpgvtUrpTI4EEWKXDs/miZ+9s9ZOQl4uj9tb4NhRYTuXNrztrUAD1PPNP5XkFi0vosUwz7GbGGchZSw==";
        };
        packageLock = final.fetchurl {
          url = "https://raw.githubusercontent.com/nicobailon/pi-web-access/v${version}/package-lock.json";
          hash = "sha256-4N826z4YyczVgzxLO2h9h+gv283cWnlbP21X/BcwEn0=";
        };
      in
      final.buildNpmPackage {
        pname = "pi-web-access";
        inherit version src;
        npmDepsHash = "sha256-QKmgVmIvqLbqnUmKBKniT0CvNIgZWZ9mUkha0LJMMVQ=";

        postPatch = ''
          cp ${packageLock} package-lock.json
          find . -type f -name '*.ts' -exec sed -i \
            -e 's|@mariozechner/pi-coding-agent|@earendil-works/pi-coding-agent|g' \
            -e 's|@mariozechner/pi-ai|@earendil-works/pi-ai|g' \
            -e 's|@mariozechner/pi-tui|@earendil-works/pi-tui|g' \
            {} +
        '';

        dontNpmBuild = true;
        dontNpmCheck = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out/
          rm -f $out/package-lock.json $out/node_modules/.package-lock.json
          mkdir -p $out/node_modules/typebox
          tar -xzf ${typebox_1_1_38} --strip-components=1 -C $out/node_modules/typebox
          runHook postInstall
        '';
        meta = {
          description = "Pi coding agent extension: web search, URL fetching, GitHub repo cloning, PDF extraction, and video analysis";
          homepage = "https://github.com/nicobailon/pi-web-access";
          license = lib.licenses.mit;
        };
        passthru = {
          pname = "pi-web-access";
          inherit version;
          piExtension = true;
        };
      };
    # @sherif-fanous/pi-catppuccin — Catppuccin themes for pi's TUI.
    # https://github.com/sherif-fanous/pi-catppuccin
    pi-catppuccin = mkPiExtensionFromNpm {
      pname = "@sherif-fanous/pi-catppuccin";
      version = "0.2.0";
      hash = "sha512-OpCHxwBciVMvq2FndsO1A4ab37MWwXM/Sd6BMZ4InKGJf/XaaYP53eY3ZVUwazJ7sQSp5dhh7pE0+ZLIXjJfgg==";
    };
  };
}
