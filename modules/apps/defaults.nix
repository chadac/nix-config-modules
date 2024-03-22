{ inputs, ... }:
{
  apps.host-config = {
    tags = [ "defaults" ];
    nixos = { host, pkgs, ... }: {
      nix = {
        registry = {
          # nixpkgs.flake = inputs.nixpkgs;
        };
        settings = {
          trusted-users = [ "root" ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      # nixpkgs.pkgs = host._internal.pkgs;
      system.stateVersion = "24.05";
    };
  };
  defaultTags = {
    defaults = true;
  };
}
