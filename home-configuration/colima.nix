{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    docker-client
    colima
    lima
  ];

  home.sessionVariables = rec {
    COLIMA_VM = "default";
    COLIMA_VM_SOCKET = "${config.home.homeDirectory}/.colima/${COLIMA_VM}/docker.sock";
    DOCKER_HOST = "unix://${COLIMA_VM_SOCKET}";
    TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "${COLIMA_VM_SOCKET}";
  };

  home.shellAliases = {
    colima-create-default = ''
      colima start \
         --profile default \
         --ssh-config=false \
         --activate \
         --arch aarch64 \
         --cpu 2 \
         --disk 40 \
         --memory 8 \
         --mount ${config.home.homeDirectory}:w \
         --mount-inotify \
         --ssh-agent \
         --vm-type vz \
         --vz-rosetta \
         --verbose'';
  };
}
