# I don't want to force anybody to use single-user configs, so it's
# possible to enable or disable this with tags. In the future I may
# specify a separate module for multi-user configurations.

{ lib, ... }: let
  inherit (lib)
    mkOption
    types
  ;
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          username = mkOption {
            type = types.str;
            default = "user";
            description = ''
              The username of the single user for this system.
            '';
          };
          email = mkOption {
            type = types.str;
            default = "";
            description = ''
              The email for the single user.
            '';
          };
          homeDirectory = mkOption {
            type = types.path;
            default = "/home/${config.username}";
            description = lib.mdDoc ''
              The path to the home directory for this user. Defaults to
              `/home/<username>`
            '';
          };
        };
      }));
    };
  };

  config = {
    apps.single-user-config = {
      tags = [ "single-user" ];
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
      home = { host, ... }: {
        home = {
          inherit (host) username homeDirectory;
        };
      };
    };
    defaultTags = {
      single-user = true;
    };
  };
}
