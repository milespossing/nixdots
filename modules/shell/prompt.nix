{
  flake.modules.homeManager.base = {
    programs.starship.enable = true;
    programs.starship.settings = {
      aws.disabled = true;
      directory.read_only = " 󰌾";
      direnv.disabled = false;
      docker_context.symbol = " ";
      fennel.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      haskell.symbol = " ";
      java.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      python.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      time.disabled = true;
      os.symbols = {
        Linux = " ";
        Macos = " ";
        NixOS = " ";
        Windows = "󰍲 ";
      };
    };
  };
}
