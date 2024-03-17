{
  description = "Modules for managing system configurations.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    flake.flakeModule = import ./flakeModule.nix;
    systems = [ ];
  };
}
