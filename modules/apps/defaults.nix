# Provides reasonable defaults to get started... mainly
# stuff to ensure your system can reliably rebuild this flake
# in the future.

{ inputs, ... }:
{
  apps.host-config = {
    tags = [ "defaults" ];
    nixos = { host, pkgs, ... }: {
      nix = {
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };
        settings = {
          trusted-users = [ "root" ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    };
  };
  defaultTags = {
    defaults = true;
  };
}
