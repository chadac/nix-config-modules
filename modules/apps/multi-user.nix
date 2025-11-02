{ lib, ... }: let
  inherit (lib)
    mkOption
    types
  ;
  userType = types.submodule({ name, config, ... }: {
    username = mkOption {
      type = types.str;
      default = name;
      description = ''
        The name of the user.
      '';
    };
    email = mkOption {
      type = types.str;
      default = null;
      description = "The user email.";
    };
    homeDirectory = mkOption {
      type = types.str;
      default = "/home/${config.username}";
      description = lib.mkDoc ''
        The path to the home directory for this user. Defaults to
        `/home/<username>`.
      '';
    };
    nixosUser = mkOption {
      type = types.nullOr types.deferredModule;
      default = null;
      description = lib.mkDoc ''
        Additional NixOS user-specific config. Goes into `users.users.<username>`.
      '';
    };
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          users = types.attrsOf userType;
        };
      }));
    };
  };
  config = {
    apps.multi-user-config = {
      tags = [ "multi-user" ];
      nixos = { host, ... }: {
        nix.settings = {
          trusted-users = [ host.username ];
        };
        users.users.${host.username} = {
          isNormalUser = true;
          home = host.homeDirectory;
          group = host.username;
          description = host.username;
        };
        users.groups.${host.username} = {};
      };

      darwin = { host, ... }: {
        nixpkgs.pkgs = host._internal.pkgs;
        nix.settings = {
          trusted-users = [ host.username ];
          experimental-features = [ "nix-command" "flakes" ];
        };
        users.users.${host.username} = {
          home = host.homeDirectory;
        };
      };

      home = { host, ... }: {
        home = {
          inherit (host) username homeDirectory;
        };
      };
    };
    defaultTags = {
      multi-user = false;
    };
  };
}
