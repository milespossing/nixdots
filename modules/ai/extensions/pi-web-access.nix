{ ... }:
{
  # pi-web-access — web search, URL fetching, GitHub repo cloning, PDF
  # extraction, YouTube understanding, and local video analysis.
  # https://github.com/nicobailon/pi-web-access
  pi.extensions.pi-web-access = {
    pname = "pi-web-access";
    version = "0.10.7";
    hash = "sha512-HbRN2dMGpgvtUrpTI4EEWKXDs/miZ+9s9ZOQl4uj9tb4NhRYTuXNrztrUAD1PPNP5XkFi0vosUwz7GbGGchZSw==";
    meta = {
      description = "Pi coding agent extension: web search, URL fetching, GitHub repo cloning, PDF extraction, and video analysis";
      homepage = "https://github.com/nicobailon/pi-web-access";
    };

    build =
      {
        pkgs,
        fetchNpm,
        src,
        meta,
        passthru,
        ...
      }:
      let
        packageLock = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/nicobailon/pi-web-access/v0.10.7/package-lock.json";
          hash = "sha256-4N826z4YyczVgzxLO2h9h+gv283cWnlbP21X/BcwEn0=";
        };
        typebox = fetchNpm {
          pname = "typebox";
          version = "1.1.38";
          hash = "sha512-pZ0aQPmMmXoUvSbeuWf/Hzsc+avNw/Zd6VeE8CFgkVGWyuHPJvqeJJDeJqLve+K70LvjYIoleGcoJHPT17cWoA==";
        };
      in
      pkgs.buildNpmPackage {
        inherit (passthru) pname version;
        inherit src meta passthru;
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
          tar -xzf ${typebox} --strip-components=1 -C $out/node_modules/typebox
          runHook postInstall
        '';
      };
  };
}
