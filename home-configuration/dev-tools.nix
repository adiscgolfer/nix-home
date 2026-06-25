{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # Fonts
    (nerd-fonts.meslo-lg)

    # Modern replacements for standard tools
    eza           # Modern ls with colors/icons/git integration
    ripgrep       # Fast grep replacement (rg)
    fd            # Better find command
    fzf           # Fuzzy finder for everything
    bottom        # replacement for top
    watchexec     # watch this directory and re-run this command when it changes

    # JSON/YAML/Data tools
    jq            # JSON processor
    yq-go         # YAML processor (Go version)

    # API/HTTP tools
    httpie        # User-friendly HTTP client (better than curl for APIs)

    # Git tools
    gh            # GitHub CLI (PRs, issues, etc)
    lazygit       # Interactive git TUI

    # Docker tools
    dive          # Explore Docker image layers
    lazydocker    # Interactive Docker TUI

    # Go development
    go            # Go compiler and tools
    gopls         # Go language server (includes goimports and other tools)
    golangci-lint # Go linter
    delve         # Go debugger

    # Node.js
    nodejs

    # .NET/C# development
    # dotnet-sdk_9  # .NET 9 SDK (includes runtime, latest LTS)

    # Utilities
    tree          # Visualize directory structure
    tldr          # Simplified man pages
    watch         # Monitor command output
    cmux          # macOS terminal for AI coding agents (built on Ghostty)

    # Claude Code
    claude-code
  ];

  # Enhanced Git diffs with delta
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };

  # FZF for fuzzy finding
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  # Shell aliases for better CLI tools
  home.shellAliases = {
    ls = "eza";
    lt = "eza --tree --level=2";
    cat = "bat";
    grep = "rg";
    find = "fd";
    lg = "lazygit";
  };
}
