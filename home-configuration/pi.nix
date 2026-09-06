{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Pi (earendil-works) coding agent config. Home Manager does not install Pi
  # itself - it's npm-installed separately, see https://pi.dev. This only
  # manages the config files under ~/.pi/agent; Pi's own runtime state
  # (auth, sessions, npm package trees) stays unmanaged.
  home.file.".pi/agent/settings.json".source = ./files/pi/settings.json;
  home.file.".pi/agent/extensions".source = ./files/pi/extensions;
}
