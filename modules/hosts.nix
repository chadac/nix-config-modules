{ inputs, lib, ... }@args:
let
  inherit (lib)
    filterAttrs
    mkOption
    types
  ;
  appType = import ./lib/appType.nix args;

  mkModuleOption = description: mkOption {
    type = types.deferredModule;
    default = { };
    inherit description;
  };

  hostType = types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = "";
        description = ''
          The name of the host, as specified in the attribute set. Use this to
          target per-host behavior. Generally you should not set this yourself;
          it will be set automatically when you define the host.
        '';
      };
      kind = mkOption {
        type = types.enum [ "nixos" "home-manager" ];
        default = "nixos";
        description = lib.mdDoc ''
          The type of host this is. Two options:

          * `nixos`: A NixOS system configuration. Generates NixOS with
            home-manager installed.
          * `home-manager`: A home-manager configuration. Generates only the
            home-manager configuration for the host.
        '';
      };
      system = mkOption {
        type = types.str;
        default = null;
        description = lib.mdDoc ''
          The system that this host runs on. This is used to initialize
          `nixpkgs`.
        '';
      };

      nix-config = mkModuleOption ''
        additional configurations for nix-config-modules.

        Use this to add additional custom apps or customize apps
        on a per-host basis.
      '';
      nixpkgs = mkModuleOption "nixpkgs configurations";
      nixos = mkModuleOption "NixOS configurations";
      home = mkModuleOption "home-manager configurations";
    };

    config = {
      inherit name;
    };
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf hostType;
      default = { };
      description = ''
        Individual NixOS/home-manager configurations for individual machines or
        classes of machines.

        Each host initializes a separate copy of `nixpkgs` and has its own
        initialization of `nixosConfigurations` and `homeConfigurations`
        depending on its type.
      '';
      example = ''
        hosts.odin = {
          # specifies that this builds the entire NixOS
          kind = "nixos";
          # specifies the system to build for
          system = "x86_64-linux";
        };
      '';
    };
  };
}
