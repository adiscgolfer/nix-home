{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Alacritty terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      # Terminal configuration
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      # Window settings
      window = {
        opacity = 1.0;
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "buttonless";  # macOS-style with no title bar buttons
        option_as_alt = "Both";      # Use Option as Alt key (useful for emacs-style bindings)
      };

      # Font configuration
      font = {
        size = 16.0;
        normal = {
          family = "MesloLGS Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS Nerd Font";
          style = "Italic";
        };
      };

      # Dracula color scheme (matching your delta config)
      colors = {
        primary = {
          background = "#282a36";
          foreground = "#f8f8f2";
        };
        cursor = {
          text = "CellBackground";
          cursor = "#f8f8f2";
        };
        normal = {
          black = "#21222c";
          red = "#ff5555";
          green = "#50fa7b";
          yellow = "#f1fa8c";
          blue = "#bd93f9";
          magenta = "#ff79c6";
          cyan = "#8be9fd";
          white = "#f8f8f2";
        };
        bright = {
          black = "#6272a4";
          red = "#ff6e6e";
          green = "#69ff94";
          yellow = "#ffffa5";
          blue = "#d6acff";
          magenta = "#ff92df";
          cyan = "#a4ffff";
          white = "#ffffff";
        };
      };

      # Performance and behavior
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Cursor settings
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
      };

      # Key bindings
      keyboard.bindings = [
        { key = "N"; mods = "Command"; action = "CreateNewWindow"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "W"; mods = "Command"; action = "Quit"; }
        { key = "Plus"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
      ];

      # General settings
      general = {
        live_config_reload = true;
        working_directory = "InheritApplicationCwd";
      };
    };
  };
}
