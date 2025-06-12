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
      enabled = true;
      source = ./wsl-cheats;
      destination = ".cheats/wsl";
    }
    {
      type = "git";
      enabled = true;
      owner = "denisidoro";
      repo = "cheats";
      rev = "1339965e9615ce00174cc308a41279d9c59aa75f";
      sha256 = "0j2xqlq4a104jk1gmr9xr0803r9wfjv6apy6s1pgha0661mh1yy0";
    }
    {
      type = "git";
      enabled = true;
      owner = "denisidoro";
      repo = "navi-tldr-pages";
      rev = "636c02e165683986f5e15bb14b66b8bc0df478a1";
      sha256 = "0vrcl272nrvrkic5aqxqbh61v9vzcqp76nm2hgjpvgxvgcg6rhln";
    }
  ];
  cheatsPaths = lib.flatten (
    lib.filter (entry: entry != null) (
      map (
        cheat:
        if !cheat.enabled then
          null
        else if cheat.type == "git" then
          let
            fetchedRepo = pkgs.fetchFromGitHub {
              owner = cheat.owner;
              repo = cheat.repo;
              rev = cheat.rev;
              sha256 = cheat.sha256;
            };
          in
          "${fetchedRepo}"
        else if cheat.type == "local" then
          "${config.home.homeDirectory}/${cheat.destination}"
        else
          null
      ) cheats
    )
  );

  cheatsFiles = lib.lists.foldl (
    acc: cheat:
    if cheat.type == "local" && cheat.enabled then
      acc
      // {
        "${cheat.destination}" = {
          source = cheat.source;
          recursive = true;
        };
      }
    else
      acc
  ) { } cheats;
in
{
  programs.navi = {
    enable = true;
    settings = {
      cheats = {
        paths = cheatsPaths;
      };
    };
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  home.file = cheatsFiles;
}
