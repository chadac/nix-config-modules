{ inputs, ... }: {
  perSystem.checks = { pkgs, lib, system, ... }: let
    module = {
      hosts.main = {
        users = {
          root = {
          };
          user1 = {
            tags.tag1 = true;
          };
          user2 = {
            tags.tag2 = true;
          };
        };
      };
      apps = {
        app1 = {
          tags = [ "tag1" ];
          nixos = { pkgs }: {
            environment.systemPackages = [ pkgs.git ];
          };
          home = { pkgs }: {
          };
        };
        app2 = {
          tags = [ "tag2" ];
          nixos = { pkgs }: {
            environment.systemPackages = [ pkgs.bash ];
          };
        };
      };
    };
    nix-config = lib.evalModules {
      modules = [
        ../modules/all-modules.nix
      ];
    };
    home-user1 = nix-config.homeConfigurations.${system}.main-user1;
    home-user2 = nix-config.homeConfigurations.${system}.main-user1;
    nixos = nix-config.nixosConfigurations.${system}.main;
    module = {
    };
  in {
    multi-user = lib.runTests {
      enablesNixConfig = {
        expr = nixos;
        expected = {
          environment.systemPackages = with pkgs; [ git bash ];
        };
      };
    };
  };
  # perSystem.checks.multi-user = { pkgs, lib, system, ... }: let
  # in pkgs.nixosTest {
  #   nodes.machine = nix-config.nixosConfigurations.${system}.main;
  #   testScript = ''
  #     machine.start()
  #     machine.wait_for_unit("dafault.target")
  #     machine.
  #   '';
  # };
}
