{
  description = "Home nix configuration";

  inputs = {
    #TODO: This is set to bleeding edge, change it to a nix release if you want stability.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      devshell,
      ...
    }:

    let
      system = "aarch64-darwin";
      username = "adiscgolfer";
      # Run `scutil --get LocalHostName` on your Mac to find this
      hostname = "mbp-adg";
    in
    {
      # Build darwin configuration using:
      # $ darwin-rebuild switch --flake ".#$HOST"
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit self inputs;
        };
        modules = [
          ./darwin-configuration
          { nixpkgs.hostPlatform = system; }
        ];
      };

      # Build home configuration using:
      # $ home-manager switch --flake ".#$USER"
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };
        extraSpecialArgs = {
          inherit self inputs;
        };

        modules = [
          ./home-configuration
          { home.username = username; }
        ];
      };

      devShells."${system}".default =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              devshell.overlays.default
            ];
          };
        in
        pkgs.devshell.mkShell (
          { pkgs, ... }:
          {
            commands = [
              {
                help = "Nix CLI Helper";
                package = pkgs.nh;
              }
              {
                help = "Home Manager";
                package = pkgs.home-manager;
              }
              {
                help = "Nix Darwin";
                package = inputs.nix-darwin.packages.${system}.darwin-rebuild;
              }
              {
                help = "Update your nix setup. Update flake.lock, switch, show what changed, then gc)";
                name = "update-everything";
                command =
                  let
                    nh = "${pkgs.nh}/bin/nh";
                    nix = "${pkgs.nix}/bin/nix";
                    profilesDir = "/nix/var/nix/profiles";
                    hmProfilesDir = "$HOME/.local/state/nix/profiles";
                  in
                  ''
                    pre_sys=$(ls -d ${profilesDir}/system-*-link 2>/dev/null | sort -V | tail -1) && \
                    pre_hm=$(ls -d ${hmProfilesDir}/home-manager-*-link 2>/dev/null | sort -V | tail -1) && \
                    ${nh} darwin switch -u --commit-lock-file . && \
                    ${nh} home switch . && \
                    echo "" && \
                    echo "######################################################" && \
                    echo "##         WHAT CHANGED — darwin/system             ##" && \
                    echo "######################################################" && \
                    if [ -n "$pre_sys" ]; then
                      ${nix} store diff-closures "$pre_sys" ${profilesDir}/system
                    else
                      echo "Only one system generation — run update-everything again next time"
                    fi && \
                    echo "" && \
                    echo "######################################################" && \
                    echo "##         WHAT CHANGED — home-manager              ##" && \
                    echo "######################################################" && \
                    if [ -n "$pre_hm" ]; then
                      ${nix} store diff-closures "$pre_hm" ${hmProfilesDir}/home-manager
                    else
                      echo "Only one home-manager generation — run update-everything again next time"
                    fi && \
                    echo "" && \
                    echo "######################################################" && \
                    echo "##                    GC                            ##" && \
                    echo "######################################################" && \
                    ${nh} clean all --keep 2
                  '';
              }
            ];
            motd = ''
              {202}🔨 Welcome to devshell{reset}
              $(type -p menu &>/dev/null && menu)

              [Quick help]
              'nh darwin switch .'  - Activate OsX/darwin changes
              'nh home switch .'    - Activate Home changes
              'nh clean all'        - Collect Garbage
            '';
          }
        );
    };
}
