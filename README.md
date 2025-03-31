# nix-config-modules

A module system on top of NixOS, home-manager, nixpkgs, and nix-darwin
to simplify your flake-based Nix connfigurations. The main
contribution of this setup is an abstraction of your configuration
into *apps* (which can contain combined
NixOS/Home-manager/Nixpkgs/nix-darwin configurations) and *hosts*
(which allow you to specify your system configuration and which apps
you want to use).

With this module setup, it is much easier to colocate similar
configurations in the same file. For example, rather than storing your
Emacs configuration in three separate files, in nix-config-modules,
emacs would be configured with:

```nix
  { inputs, ... }:
  nix-config.apps.emacs = {
    tags = [ "development" ];
    # we can separately configure settings to the `nixpkgs` setup
    nixpkgs = {
      # this means you can conditionally apply overlays when desired
      params.overlays = [ inputs.emacs-overlay.overlay ];
      # you can also configure allowed unfree packages on a per-app basis
      packages.unfree = [ "terraform" ];
    };
    nixos = {
      services.emacs.enable = true;
    };
    home = { pkgs, ... }: {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-unstable;
      };
    };
  };
```

You can then configure a host to use emacs with:

```nix
nix-config.hosts.my-host = {
  kind = "nixos";
  system = "x86_64-linux";
  # <...>

  # install any app marked with the "development" tag
  tags.development = true;

  # or you can directly enable emacs with
  nix-config = {
    apps.emacs.enable = true;
  };
};
```

This enables you to compose a mix of configurations for many systems
together *without* needing to repeat yourself or design a mechanism
for selectively enabling/disabling features on a host-by-host basis.

## Getting started

This uses [flake-parts](https://flake.parts). You don't have to (and I
built it without any explicit dependencies on it) but I leave it as an
exercise to the reader to figure out how to use this otherwise.

A sample config may look like:

```nix
{
  description = "My Nix system configuration with nix-config-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-config-modules.url = "github:chadac/nix-config-modules";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    # import nix-config-modules
    imports = [ inputs.nix-config-modules.flakeModule ];

    # this avoids errors when running `nix flake show`
    systems = [ ];

    nix-config = {
      # Tags are described below in more detail: You can use these as an
      # alternative to enabling/disabling applications.
      defaultTags = {
        # by default we will not install packages tagged with "development"
        development = false;
      };

      # Unlike regular Nix, you can bundle nixpkgs/NixOS/home-manager logic together
      apps.emacs = {
        tags = [ "development" ];
        nixpkgs.params.overlays = [
          inputs.emacs-overlay.overlay
        ];
        nixos = {
          services.emacs.enable = true;
        };
        home = { pkgs, ... }: {
          programs.emacs = {
            enable = true;
            package = pkgs.emacs-unstable;
          };
        };
      };

      hosts.my-host = {
        # host types can be "nixos" and "home-manager"
        # "nixos" is for systems that build NixOS; home-manager is bundled with it
        # "home-manager" is for systems that install just HM (for example, darwin etc)
        kind = "nixos";
        # defines the system that your host runs on
        system = "x86_64-linux";
        # on single user systems you can specify your username straight up.
        # multi-user support is "upcoming"
        username = "chadac";
        # optional metadata... useful for stuff like Git
        email = "chad@cacrawford.org";
        # you can customize your home directory, otherwise defaults to
        # `/home/<username>`
        homeDirectory = "/home/chadac";
        tags = {
          # now we tell Nix that our host needs any apps marked as
          # 'development'. This enables simplified host configurations
          # while also empowering users to still fully customize hosts
          # when needed.
          development = true;
          # this is a predifined tag; for apps that are automatically
          # included and optionally enabled, see <modules/apps>
          getting-started = true;
        };
      };
    };
  };
}
```

This will create a basic Flake with some predefined defaults for a
single-user NixOS system with home-manager enabled. You may then
build/switch to the system using:

    nixos-rebuild switch --flake .#my-host

Or with home-manager:

    home-manager switch --flake .#my-host

Since this is layered with `flake-parts` you may then choose to
manage/deploy your hosts however you wish.

For a more in-depth example of how this can be used, see
[github:chadac/dotfiles](https://github.com/chadac/dotfiles).

### Importing existing NixOS/home-manager modules

If you have NixOS/home-manager configurations specified in a standard
`configuration.nix` or `home.nix`, you can import them without needing
to refactor anything. This enables you to onboard to using Flakes for
your configuration.

To import existing configurations to a **single host**:

```nix
  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.nix-config-modules.flakeModule ];

    systems = [ ];

    nix-config = {
      hosts.my-host = {
        kind = "...";
        system = "...";

        # each host can specify custom nixos/home/nixpkgs attributes to customize
        # their own configuration
        nixos = {
          imports = [ ./configuration.nix ];
        };
        home = {
          imports = [ ./home.nix ];
        };
        # OPTIONAL: you can disable any apps that automatically add configurations.
        # See <modules/apps> for details on what each of these do.
        defaultTags = {
          defaults = false;
          single-user = false;
          home-manager = false;
        };
      };
    };
```

To import existing configurations **globally**:

```nix
  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.nix-config-modules.flakeModule ];
    systems = [ ];
    nix-config = {
      modules = {
        nixos = [ ./configuration.nix ];
        home-manager = [ ./home.nix ];
      };
      hosts.my-host = {
        # you will still need to specify `system` and `kind`
        kind = "...";
        system = "...";
      };
    };
```

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

```nix
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
    packages.unfree = [
      # just for the example... assume it's unfree
      "xfce"
    ];
  };
}
```

No more need to manage configurations for two packages in separate
places.

#### Tag-based module management

Unlike regular home-manager and NixOS, the types of hosts that I
manage tend to be fairly similar. The usual approach of customizing
something like:

```nix
# host 1
xsession.windowManager.i3.enable = true
xsession.windowManager.sway.enable = false;

# host 2
xsession.windowManager.i3.enable = false;
xsession.windowManager.sway.enable = true;
```

is pretty annoying when 99% of the time, the rest of the
configurations will remain the same. To simplify host configuration,
`nix-config-modules` has a tag-based app management system as
well. This means that you can use

```nix
my-host.tags.wayland = true;
```

to conditionally configure which apps are deployed to each system.

NOTE: This is an *optional* feature. If `enable` is specified (either
`enable = true` or `enable = false`), then that overrides tag behavior.

For example, a host can similarly disable `emacs` with:

```nix
hosts.odin = {
  nix-config = {
    apps.emacs.enable = false;
  };
};
```

## Usage

### Creating apps

Apps are basic configurations that combine NixOS, home-manager and
nixpkgs configurations. A basic example might be:

```nix
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
```

You may also use this to customize the import of `nixpkgs`; for
example:

```nix
{ inputs, ... }: {
  nix-config.apps.emacs = {
    tags = [ "development" ];
    home = <...>;
    nixpkgs = {
      overlays = [ inputs.emacs-overlay.overlays.default ];
    }
  };
}
```

And of course, host tags may not only customize the enabling/disabling
of apps but also their configuration:

```nix
nixpkgs = { lib, host, ... }: {
  overlays = lib.mkIf host.tags.bleeding-edge [ inputs.emacs-overlay.overlays.default ];
};
```

### Fast apps

Sometimes we'd like to have some apps automatically installed to our
user's system. For that, use the trait `homeApps`:

```nix
homeApps = [{
  tags = [ "entertainment" ];
  packages = [ "vlc" "spotify" "tidal-hifi" ];
}]
```

This creates the following equivalent configuration:

```nix
apps.vlc = {
  tags = [ "entertainment" ];
  home = { pkgs, ... }: {
    home.packages = [ pkgs.vlc ];
  };
};

# < .. repeat for spotify, tidal-hifi .. >
```

### Per-host configuration

It's also possible to manage NixOS/Home Manager/nixpkgs configurations
on a per-host basis:

```nix
nix-config.hosts.my-host = {
  # <...>
  nixos = {
    imports = [ ./my-host/hardware-configuration.nix ];
  };
};
```

## FAQ

### Can you provide a template to get started?

meh

### Can you provide a means of disabling home-manager with NixOS?

Technically you can disable home-manager with

```nix
nix-config.defaultTags.home-manager = lib.mkForce false;
```

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
