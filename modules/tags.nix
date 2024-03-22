{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;
  cfg = config;
  hostSubmodule = types.submodule ({ config, ... }: {
    options = {
      tags = mkOption {
        type = types.attrsOf types.bool;
        default = { };
        description = ''
          Boolean tags to indicate whether certain features should be enabled or disabled.
        '';
        apply = tags: cfg.defaultTags // tags;
      };
    };
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
    };
    defaultTags = mkOption {
      type = types.attrsOf types.bool;
      description = lib.mdDoc ''
        The default values for each tag used by the hosts.

        Note that for a host to specify a tag, an intial value must be
        specified in `defaultTags`.
      '';
    };
  };
}
