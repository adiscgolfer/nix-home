{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.sessionVariables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "eza -la --git";
      h = "history";
    };
    initContent = ''
      [[ -f ~/.secrets ]] && source ~/.secrets
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  programs.starship = {
      enable = true;
      settings = {
        directory = {
          style = "bold blue";
          truncation_length = 3;
          fish_style_pwd_dir_length = 1;
        };

        git_branch = {
          symbol = " ";
          style = "bold 242"; # Darker grey
          format = "on [$symbol$branch]($style) ";
        };

        time = {
          disabled = false;
          style = "bold 242";
          format = "at [$time]($style) ";
        };

        cmd_duration = {
          style = "242";
          format = "took [$duration]($style) ";
        };

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };

        nix_shell = {
          symbol = "❄️ ";
          style = "bold blue";
          format = "via [$symbol$state( ($name))]($style) ";
        };
      };
    };

  programs.bat.enable = true;
  programs.bottom.enable = true;

  services.ssh-agent.enable = true;

  programs.atuin = {
    enable = true;
    # daemon.enable = true; # still experimental
  };
}
