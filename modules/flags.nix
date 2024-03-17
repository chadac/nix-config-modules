{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          tags = mkOption {
            type = types.attrsOf types.bool;
            default = { };
            description = ''
              Labels to
            '';
          };
        };
      });
    };
    defaultTags = mkOption {
      type = types.attrsOf types.bool;
    };
  };
}
