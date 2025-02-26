# This provides default home-manager/NixOS configurations to get
# started with using nix-config-modules. I STRONGLY recommend you copy
# this into your own app/modules and instantiate it separately there;
# following this config will leave you at risk of things exploding with
# future upgrades.

{ ... }: {
  apps.getting-started = {
    tags = ["getting-started"];
    nixos = {
      system.stateVersion = "24.05";
    };
    home = {
      home.stateVersion = "23.11";
    };
    darwin = {
      system.stateVersion = 5;
    };
  };

  defaultTags = {
    getting-started = false;
  };
}
