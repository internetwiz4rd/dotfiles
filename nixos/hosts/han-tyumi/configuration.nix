# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  stellae,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  imports = [
    ./../../modules/nixos
    inputs.catppuccin.nixosModules.catppuccin
  ];

  modules = {
    niri-config.enable = true;

    terminal.extra.enable = true;
    media-tools = {
      enable = true;
      extra.enable = true;
    };
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";

    gtk = {
      icon = {
        enable = true;
        flavor = "mocha";
        accent = "blue";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # package = pkgsUnstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  boot = {
    # This is to fix frequent Bluetooth audio dropouts.
    extraModprobeConfig = ''
      # Keep Bluetooth coexistence disabled for better BT audio stability
      options iwlwifi bt_coex_active=0

      # Enable software crypto (helps BT coexistence sometimes)
      options iwlwifi swcrypto=1

      # Disable power saving on Wi-Fi module to reduce radio state changes that might disrupt BT
      options iwlwifi power_save=0

      # Disable Unscheduled Automatic Power Save Delivery (U-APSD) to improve BT audio stability
      options iwlwifi uapsd_disable=1

      # Disable D0i3 power state to avoid problematic power transitions
      options iwlwifi d0i3_disable=1

      # Set power scheme for performance (iwlmvm)
      options iwlmvm power_scheme=1
    '';

    # TODO: Make this compatible with building a live ISO image
    # Use latest kernel.
    # kernelPackages = lib.mkForce pkgsUnstable.linuxPackages_latest;

    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      cache.enable = true;
    };
    nixos = {
      enable = true;
      includeAllModules = true;
      options.splitBuild = true;
    };
  };

  system = {
    # Enables auto upgrades
    autoUpgrade = {
      enable = true;
      flake = "path:./../../flake.nix";
      dates = "weekly";
      allowReboot = true;
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "26.05"; # Did you read the comment?
  };

  hardware = {
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

    # OpenGL
    graphics.enable = true;
    # Most wayland compositors need this
    nvidia.modesetting.enable = true;
    opentabletdriver.enable = true;
  };

  networking = {
    firewall = {
      # Open ports in the firewall.
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

      # Or disable the firewall altogether.
      # enable = false;
    };

    hostName = baseNameOf (toString ./.); # Defines the hostname based off of the name of the parent directory

    networkmanager.enable = true; # Enable networking

    # Configure network proxy if necessary
    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };

    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # console = {
  #   earlySetup = true;
  #   packages = [ pkgs.terminus_font ];
  #   font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
  #   keyMap = "us";
  # };

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    # openssh.enable = true;

    auto-cpufreq.enable = true;

    blueman.enable = true;

    # Better tty
    kmscon = {
      enable = false;
      hwRender = true;
      useXkbConfig = true;

      extraConfig = ''
        font-name=roboto-mono
        font-size=18
      '';
    };

    # Enable tlp for laptop power management
    tlp = {
      enable = true;
      settings = {
        #   CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        #
        # CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80;

        # Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 80; # and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # and above it stops charging
      };
    };

    pipewire = {
      enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
      wireplumber.enable = true;
      # alsa = {
      #   enable = true;
      #   support32Bit = true;
      # };

      # wireplumber.extraConfig.bluetoothEnhancements = {
      #   "monitor.bluez.properties" = {
      #     "bluez5.enable-sbc-xq" = true;
      #     "bluez5.enable-msbc" = true;
      #     "bluez5.enable-hw-volume" = true;
      #     "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
      #   };
      # };
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # File system management
    gvfs.enable = true;
    udisks2.enable = true;
  };

  # Enable system power management
  powerManagement.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_DK.UTF-8";
      LC_IDENTIFICATION = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      LC_TELEPHONE = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };
  };

  systemd = {
    timers."nye" = {
      timerConfig = {
        # OnBootSec = "5m";
        # OnUnitActiveSec = "5m";
        # Alternatively, if you prefer to specify an exact timestamp
        # like one does in cron, you can use the `OnCalendar` option
        # to specify a calendar event expression.
        # Run every Monday at 10:00 AM in the Asia/Kolkata timezone.
        #OnCalendar = "Mon *-*-* 10:00:00 Asia/Kolkata";
        OnCalendar = "*-12-31 23:00:00 America/Chicago";
        Unit = "nye.service";
      };
    };
    services."nye" = {
      script = ''
        set -eu
        ${pkgs.pipewire}/bin/pipewire "nye.flac"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.roboto-mono ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${stellae.username}" = {
    description = "Stellae";
    extraGroups = [
      "audio"
      "cdrom"
      "dialout"
      "jackaudio"
      "networkmanager"
      "plugdev"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    initialPassword = "drowssap"; # It's 'password' spelled backwards
    shell = pkgs.zsh;
  };

  programs = {
    kdeconnect.enable = true;
    steam.enable = true;

    # # Forgot that this is for the weak
    # nix-ld = {
    #   enable = true;
    #   libraries = with pkgs; [
    #     # Add missing dynamic libraries for unpackaged programs here
    #   ];
    # };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation.vmware = {
    host.enable = true;
    guest.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # # VR shit
  # services.monado.enable = true;
  # programs.alvr = {
  #   enable = true;
  #   openFirewall = true;
  # };

  environment.systemPackages =
    let
      gnome-disks-exfatprogs = (
        pkgs.gnome-disk-utility.overrideAttrs (prev: {
          buildInputs = prev.buildInputs ++ (with pkgs; [ exfatprogs ]);
        })
      );

      nvim = inputs.nvim.packages.${pkgs.hostPlatform.system}.nvim;
    in
    [
      gnome-disks-exfatprogs
      nvim
    ]
    ++ (with pkgs; [
      # globalprotect-openconnect
      # kdePackages.marble
      # qgis
      # qjackctl
      # signal-export
      android-file-transfer
      android-tools
      discord
      firefox # Web browser
      fractal # Matrix chat app
      halloy
      libreoffice-fresh
      lm_sensors
      mtpfs
      nautilus
      nwg-look
      onlyoffice-desktopeditors
      openssl
      organicmaps
      prismlauncher
      signal-desktop
      stellarium
      tor
      typst
      usbutils
      vmware-workstation # Industry standard hypervisor
      zathura # Document viewer
      zotero # Citation aggregator
    ])
    ++ (with pkgsUnstable; [
      obsidian
    ]);
}
