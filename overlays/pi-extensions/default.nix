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

    # @juicesharp/rpiv-btw — `/btw` slash command. Asks a one-off
    # side question to the same primary model without polluting the
    # main conversation thread.
    # https://github.com/juicesharp/rpiv-mono
    rpiv-btw = mkPiExtensionFromNpm {
      pname = "@juicesharp/rpiv-btw";
      version = "1.20.0";
      hash = "sha512-WTyCGnNm29/yn+nIQD9uqencHQpv0unnNiorS6QWOINxttNXrf5I1oi2qmxUjG+5vz0dw0jcWUyGOWWp1CG87Q==";
    };

    # @milespossing/pi-copilot-discovery — dynamic GitHub Copilot model
    # discovery for pi. Replaces pi-ai's static catalog with the live
    # /models list from your Copilot tenant.
    # https://github.com/milespossing/pi-copilot-discovery
    pi-copilot-discovery = mkPiExtensionFromNpm {
      pname = "@milespossing/pi-copilot-discovery";
      version = "0.2.0";
      hash = "sha256-SK19DeILXDBJbl9feSxGW58Kce89DRq4UmbQNFroe3s=";
    };

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
  };
}
