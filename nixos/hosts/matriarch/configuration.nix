# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  syren,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  discoverWrapped = pkgs.symlinkJoin {
    name = "discoverFlatpakBackend";
    paths = [
      pkgs.kdePackages.discover
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/plasma-discover --add-flags "--backends flatpak"
    '';
  };
in
{
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    # Allow drawing tablet
    opentabletdriver.enable = true;

    # Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };

  security.rtkit.enable = true;

  services = {
    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;
      jack.enable = true;
      socketActivation = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    flatpak.enable = true;

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  hostName = baseNameOf (toString ./.); # Defines the hostname based off of the name of the parent directory
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    # Enable networking
    networkmanager.enable = true;
    # Open ports in the firewall.
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Allow unsupported systems
  nixpkgs.config = {
    allowUnsupportedSystem = true;
    allowUnfree = true;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];

  users.users.${syren.username} = {
    isNormalUser = true;
    description = "Syren";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "video"
      "jackaudio"
      "audio"
      "cdrom"
    ];
    shell = pkgs.zsh;
    initialPassword = "";
  };

  # Auto-sync dotfiles for Syren
  systemd = {
    timers."dotfiles" = {
      timerConfig = {
        OnBootSec = "5m";
        # OnUnitActiveSec = "5m";
        # Alternatively, if you prefer to specify an exact timestamp
        # like one does in cron, you can use the `OnCalendar` option
        # to specify a calendar event expression.
        # Run every Monday at 10:00 AM in the Asia/Kolkata timezone.
        #OnCalendar = "Mon *-*-* 10:00:00 Asia/Kolkata";
        # OnCalendar = "Mon *-*-* 04:00:00 America/Chicago";
        Unit = "dotfiles.service";
      };
    };

    services."dotfiles" = {
      script = ''
        set -eu
        pushd $HOME/dotfiles
        ${pkgs.git}/bin/git fetch --all
        ${pkgs.git}/bin/git rebase origin/master
        ${pkgs.git}/bin/git pull origin master --all
        popd
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "${syren.username}";
      };
    };
  };

  programs.zsh.enable = true;

  environment = {
    plasma6.excludePackages = with pkgs; [
      kdePackages.elisa
      kdePackages.konsole
      # kdePackages.kwrite
      kdePackages.kate
      xterm
      kdePackages.ktexteditor
    ];

    systemPackages = [
      inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.nvim
      discoverWrapped
    ]
    ++ (with pkgs; [
      aseprite
      discord
      dust # Modern `du`
      firefox
      lazygit # TUI for `git`
      obsidian
      openssl
      # prismlauncher
      signal-desktop
      unzip
      vscodium-fhs
      git
      kitty
    ]);
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
