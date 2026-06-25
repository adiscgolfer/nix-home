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
        pkgs = import nixpkgs { inherit system; };
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
                help = "Update your nix setup. Update flake.lock, and switchs (with a little gc)";
                name = "update-everything";
                command =
                  let
                    nh = "${pkgs.nh}/bin/nh";
                  in
                  "${nh} darwin switch -u --commit-lock-file . && ${nh} home switch . && ${nh} clean all";
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
