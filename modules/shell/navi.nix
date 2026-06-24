{
  flake.modules.homeManager.base =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cheats = [
        {
          type = "local";
          source = ./_navi/common;
          destination = ".cheats/common";
        }
        {
          type = "git";
          owner = "denisidoro";
          repo = "cheats";
          rev = "1339965e9615ce00174cc308a41279d9c59aa75f";
          sha256 = "0j2xqlq4a104jk1gmr9xr0803r9wfjv6apy6s1pgha0661mh1yy0";
        }
        {
          type = "git";
          owner = "denisidoro";
          repo = "navi-tldr-pages";
          rev = "636c02e165683986f5e15bb14b66b8bc0df478a1";
          sha256 = "0vrcl272nrvrkic5aqxqbh61v9vzcqp76nm2hgjpvgxvgcg6rhln";
        }
      ];
      cheatsPaths = map (
        c:
        if c.type == "git" then
          "${pkgs.fetchFromGitHub {
            inherit (c)
              owner
              repo
              rev
              sha256
              ;
          }}"
        else
          "${config.home.homeDirectory}/${c.destination}"
      ) cheats;
      localFiles = lib.listToAttrs (
        map (
          c:
          lib.nameValuePair c.destination {
            source = c.source;
            recursive = true;
          }
        ) (lib.filter (c: c.type == "local") cheats)
      );
    in
    {
      programs.navi = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        settings.cheats.paths = cheatsPaths;
      };
      home.file = localFiles;
    };
}
