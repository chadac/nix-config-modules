{ lib, ... }: let
  inherit (lib)
    mkOption
    types
  ;
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          username = mkOption {
            type = types.str;
          };
          email = mkOption {
            type = types.str;
          };
          homeDirectory = mkOption {
            type = types.path;
          };
        };
      });
    };
  };

  config = {
    apps.single-user-config = {
      tags = ["single-user"];
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
