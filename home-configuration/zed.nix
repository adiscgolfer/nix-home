{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Zed editor
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    userSettings = {
      theme = "One Dark";
      vim_mode = false;
      autosave = "on_focus_change";
    };
  };
}
