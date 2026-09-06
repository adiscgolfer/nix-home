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

      local config = {
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
        hide_tab_bar_if_only_one_tab = true,

        window_background_opacity = 0.92,
        macos_window_background_blur = 30,

        scrollback_lines = 10000,

        default_prog = { "${pkgs.zsh}/bin/zsh", "-l" },

        keys = {
          { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
          { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
          { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane { confirm = true } },
          { key = "z", mods = "CMD|SHIFT", action = wezterm.action.TogglePaneZoomState },
          { key = "LeftArrow", mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection "Left" },
          { key = "RightArrow", mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection "Right" },
          { key = "UpArrow", mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection "Up" },
          { key = "DownArrow", mods = "CMD|OPT", action = wezterm.action.ActivatePaneDirection "Down" },
          { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
          { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
          { key = "UpArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
          { key = "DownArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
        },
      }

      -- Dim unfocused windows so the focused one is obvious at a glance.
      -- Opacity only - dimming foreground text brightness made text unreadable
      -- whenever wezterm thought the window was unfocused.
      local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

      wezterm.on("window-focus-changed", function(window)
        local overrides = window:get_config_overrides() or {}
        local opacity
        if not window:is_focused() then
          opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
        end

        if overrides.window_background_opacity == opacity then
          return
        end

        overrides.window_background_opacity = opacity
        window:set_config_overrides(overrides)
      end)

      return config
    '';
  };
}
