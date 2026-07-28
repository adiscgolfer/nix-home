{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ~/.claude/settings.json itself stays unmanaged: Claude Code mutates it at
  # runtime (enabledPlugins, etc.), and a nix-store symlink would be read-only.
  home.file.".claude/statusline-command.sh" = {
    source = ./files/statusline-command.sh;
    executable = true;
  };
}
