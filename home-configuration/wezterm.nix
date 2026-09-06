{
  config,
  pkgs,
  lib,
  ...
}:

{
  # WezTerm terminal emulator
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      return {
        color_scheme = "Dracula",

        font = wezterm.font("MesloLGS Nerd Font"),
        font_size = 16.0,

        window_padding = {
          left = 8,
          right = 8,
          top = 8,
          bottom = 8,
        },
        window_decorations = "RESIZE",

        scrollback_lines = 10000,

        default_prog = { "${pkgs.zsh}/bin/zsh", "-l" },
      }
    '';
  };
}
