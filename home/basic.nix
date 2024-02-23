{ pkgs, ... }:
{
  imports = [
    ./dir-colors.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    vim
    neovim
    pass
    wget
    curl
    fd
    neofetch
    cbonsai
    babashka
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
    };
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
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Miles Possing";
    userEmail = "no-reply@possing.tech";
    ignores = [ "*~" "*.swp" ];
  };

  programs.lazygit = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-b";
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.nord;
      }
      {
        plugin = tmuxPlugins.sensible;
      }
      {
        plugin = tmuxPlugins.jump;
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
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
