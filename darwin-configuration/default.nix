{ self, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ curl ];

  system.primaryUser = "adiscgolfer";

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap"; # removes casks/brews/taps not listed here

    taps = [
      "ngrok/ngrok"
      "supabase/tap"
    ];

    casks = [
      "claude-code"
      "db-browser-for-sqlite"
      "docker-desktop"
      "ghostty"
      "iterm2"
      "ngrok"
      "opensuperwhisper"
      "stats"
      "visual-studio-code"
    ];

    brews = [
      "awscli"
      "node"
      "supabase/tap/supabase"
      "terraform"
    ];
  };

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
