{ lib, ... }:
let
  inherit (lib)
    attrValues
    listToAttrs
    mkOption
    types
  ;

in types.submodule {
  _file = __curPos.file;

  options = {
    forceEnable = mkOption {
      type = types.bool;
      default = false;
      description = "if true, enables the app ignoring all other options.";
    };
    tags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of tags that, when supplied, will enable the given app on the given host.
      '';
    };
    disableTags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of tags that will disable the given
      '';
    };
    enablePredicate = mkOption {
      type = types.functionTo types.bool;
      default = { host, app, ... }:
        app.forceEnable
        || (
          (builtins.any (tag: host.tags.${tag} or (throw "tag does not exist: '${tag}'")) app.tags)
          && !(builtins.any (tag: host.tags.${tag} or (throw "tag does not exist: '${tag}'")) app.disableTags)
        )
      ;
      description = ''
        Predicate used to determine if the given app should be enabled on the given host.

        It's recommended not to override this function, as its default behavior
        incorporates forceEnable, tags and disableTags.
      '';
    };
    home = mkOption {
      type = types.deferredModule;
      default = { };
    };
    nixos = mkOption {
      type = types.deferredModule;
      default = { };
    };
    nixpkgs = mkOption {
      type = types.deferredModule;
      default = { };
    };
  };
}
