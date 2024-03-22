# nix-config-modules

Modules to combine your NixOS, home-manager and nixpkgs
configurations.

## Getting started

This uses [flake-parts](https://flake.parts). You don't have to (and I
built it without any explicit dependencies on it) but I leave it as an
exercise to the reader to figure out how to use this otherwise.

To start:

    {
      description = "My Nix system configuration with nix-config-modules";

      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        nix-config-modules.url = "path:/home/chadac/code/github.com/chadac/nix-config-modules";
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [ inputs.nix-config-modules.flakeModule ];
        # this avoids errors when running `nix flake show`
        systems = [ ];

        nix-config = {
          hosts.my-first-host = {
            kind = "nixos";
            system = "x86_64-linux";
            username = "chadac";
            email = "chad@cacrawford.org";
            homeDirectory = "/home/chadac";
            tags = {
              getting-started = true;
            };
          };
          defaultTags = {
            development = true;
          };
          apps.emacs = {
            tags = [ "development" ];
            home = {
              programs.emacs.enable = true;
            };
          };
        };
      };
    }

This will create a basic Flake with some predefined defaults for a
single-user NixOS system with home-manager enabled. You may then
build/switch to the system using:

    nixos-rebuild switch --flake .#my-first-host

Since this is layered with `flake-parts` you may then choose to
manage/deploy your hosts however you wish.

## Why?

This is primarily an example in making it really easy to build flakes
that can do multi-host configurations while keeping stuff simple and
readable. There are a couple annoyances I've had in the past when
configuring systems with Nix:

#### Less code

So many flake-based Nix configs are hard to read as they're not really
utilizing the module system -- this is much simpler (see the "Getting
Started" example below).

#### Decentralized configurations

Many core services require special configurations both in
`home-manager` and in NixOS, or even custom configurations when
importing `nixpkgs`.

Usually this is managed by throwing configurations for the same app
into separate files, which can be a bit unreadable.

In `nix-config-modules`, the configuration for a single application
happens all in one place -- so you can now do:

    nix-config.apps.thunar = {
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.thunar ];
      };
      nixos = { pkgs, ... }: {
        programs.thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-archive-plugin
          ];
        };
      };
      nixpkgs = {
        config.allowUnfreePackages = [
          # just for the example... assume it's unfree
          "xfce"
        ];
      };
    }

No more need to manage configurations for two packages in separate
places.

#### Tag-based module management

Unlike regular home-manager and NixOS, the types of hosts that I
manage tend to be fairly similar. The usual approach of customizing
something like:

    # host 1
    xsession.windowManager.i3.enable = true;
    xsession.windowManager.sway.enable = false;

    # host 2
    xsession.windowManager.i3.enable = false;
    xsession.windowManager.sway.enable = true;

is pretty annoying when 99% of the time, the rest of the
configurations will remain the same. To simplify host configuration,
`nix-config-modules` has a tag-based app management system as
well. This means that you can use

    my-host.tags.wayland = true;

to conditionally configure which apps are deployed to each system.

NOTE: This is an *optional* feature. If `enable` is specified (either
`enable = true` or `enable = false`), then that overrides tag behavior.

## Usage

### Creating apps

Apps are basic configurations that combine NixOS, home-manager and
nixpkgs configurations. A basic example might be:

    nix-config.apps.i3 = {
      tags = [ "desktop" ];
      nixos = {
        services.xserver = {
          displayManager.defaultSession = "none+i3";
          windowManager.i3.enable = true;
        };
      };
      home = { pkgs, ... }: {
        xsession.windowManager.i3.enable = true;
        home.packages = with pkgs; [ dmenu i3status ];
      };
    };

You may also use this to customize the import of `nixpkgs`; for
example:

    { inputs, ... }:
    nix-config.apps.emacs = {
      tags = [ "development" ];
      home = <...>;
      nixpkgs = {
        overlays = [ inputs.emacs-overlay.overlays.default ];
      }
    };

And of course, host tags may not only customize the enabling/disabling
of apps but also their configuration:

    nixpkgs = { lib, host, ... }: {
      overlays = lib.mkIf host.tags.bleeding-edge [ inputs.emacs-overlay.overlays.default ];
    };

### Fast apps

Sometimes we'd like to have some apps automatically installed to our
user's system. For that, use the trait `homeApps`:

    homeApps = [{
      tags = [ "entertainment" ];
      packages = [ "vlc" "spotify" "tidal-hifi" ];
    }]

This creates the following equivalent configuration:

    apps.vlc = {
      tags = [ "entertainment" ];
      home = { pkgs, ... }: {
        home.packages = [ pkgs.vlc ];
      };
    };

    < .. repeat for spotify, tidal-hifi .. >

### Per-host configuration

It's also possible to manage NixOS/Home Manager/nixpkgs configurations
on a per-host basis:

    nix-config.hosts.my-first-host = {
      <...>
      nixos = {
        imports = [ ./my-first-host/hardware-configuration.nix ];
      };
    };

## FAQ

### Can you provide a template to get started?

meh

### Can you provide a means of disabling home-manager with NixOS?

Technically you can disable home-manager with

    nix-config.defaultTags.home-manager = lib.mkForce false;

That'll remove any NixOS integrations to make HM work.

### your tags mechanism sucks

yeah I know

### your nix code organization sucks

yeah I know

### your documentation sucks

yeah I know

### your testing sucks

yeah I know

### you're needlessly doing deferred modules and you could simplify this

ok I didn't know that
