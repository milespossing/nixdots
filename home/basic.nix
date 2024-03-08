{ pkgs, ... }:
let
  posixAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
  };
  posixInitExtra = ''
    for script in $(fd -g *.sh $HOME/.posix_functions); do
      source $script
    done
  '';
in
{
  imports = [
    ./dir-colors.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    babashka
    bitwarden-cli
    cbonsai
    cmake
    curl
    fd
    lsof
    neofetch
    neovim
    pass
    rlwrap
    vim
    wget
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file.".posix_functions" = {
    source = ./scripts/posix;
    recursive = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = posixAliases;
    initExtra = posixInitExtra;
  };

  programs.zsh = {
    enable = true;
    shellAliases = posixAliases;
    initExtra = posixInitExtra;
  };

  programs.nushell = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.navi = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.jq = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Miles Possing";
    userEmail = "no-reply@possing.tech";
    ignores = [ "*~" "*.swp" ];
    extraConfig = {
      pull.rebase = false;
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      mergetool = {
        keepBackup = false;
      };
      core = {
        editor = "nvim";
        pager = "bat";
      };
    };
  };

  programs.lazygit = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-b";
    clock24 = true;
    newSession = true;
    extraConfig = ''
      bind - split-window -v
      bind | split-window -h
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.nord;
      }
      {
        plugin = tmuxPlugins.yank;
      }
      {
        plugin = tmuxPlugins.jump;
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
      }
      {
        plugin = tmuxPlugins.fuzzback;
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
        extraConfig = "set -g mouse";
      }
    ];
  };

  programs.eza = {
    enable = true;
    icons = true;
    git = true;
  };

  programs.gpg = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
