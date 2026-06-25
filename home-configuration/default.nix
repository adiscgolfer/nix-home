{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
  ];

  imports = [
    ./zsh.nix
    ./colima.nix
    ./dev-tools.nix
    ./alacritty.nix
    ./ollama.nix
  ];

  programs.home-manager.enable = true;

  home.homeDirectory = "/Users/${config.home.username}";

  home.packages = with pkgs; [ curl ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Eric Prickett";
      user.email = "adiscgolfer@gmail.com";
      github.user = "adiscgolfer";
      init.defaultBranch = "main";
    };
    includes = [
      {
        condition = "gitdir:~/projects/work/";
        contents = {
          user.email = "work@company.com";
          github.user = "work-github-username";
        };
      }
    ];
    lfs.enable = true;
  };

  # Direnv is a great tool, you should use it see https://direnv.net/
  programs.direnv.enable = true;
  # Extra Nixy features for direnv, which you should also use.
  programs.direnv.nix-direnv.enable = true;

  # The state version is required and should stay at the version you
  # originally installed.
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.11";
}
