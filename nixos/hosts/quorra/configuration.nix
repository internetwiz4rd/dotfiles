{
  config,
  pkgs,
  inputs,
  modulesPath,
  nixos,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares.nix")
    ./../../modules/nixos/niri-config.nix
    inputs.catppuccin.nixosModules.catppuccin
  ];

  isoImage.edition = lib.mkDefault "niri";
  isoImage.configurationName = "Quorra";

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking = {
    hostName = baseNameOf (toString ./.); # Defines the hostname based off of the name of the parent directory
    networkmanager.enable = true; # Enable networking
  };

  users.users."${nixos.username}" = {
    shell = pkgs.zsh;
  };

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.roboto-mono ];

  programs = {
    niri.enable = true;
    zsh.enable = true;
  };

  services = {
    dunst.enable = true;

    displayManager = {
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };
  };

  environment = {
    etc."wallpaper.png".source = ./wallpaper.png;

    pathsToLink = [ "/share/calamares" ];

    sessionVariables = {
      # If your cursor becomes invisible
      # WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use wayland
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      WAYLAND_DISPLAY = "1";
      NIXOS_OZONE_WL = 1;
    };

    systemPackages =
      let
        nvim = inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.nvim;
        gnome-disks-exfatprogs = (
          pkgs.gnome-disk-utility.overrideAttrs (prev: {
            buildInputs = prev.buildInputs ++ (with pkgs; [ exfatprogs ]);
          })
        );
      in
      [
        gnome-disks-exfatprogs
        nvim
      ]
      ++ (with pkgs; [
        brightnessctl
        dust # Modern `du`
        eza # Modern `ls`
        fastfetch # Fetch system details; `neofetch` replacement
        fd # Modern `find`
        fzf # Fast fuzzy finder
        gcc # GNU Compiler Collection
        git # The distributed VCS
        htop-vim # Interactive process viewer with vim bindings
        jq # Print and parse `.json`
        just # Just a simple command runner
        kitty # Terminal Emulator
        lazygit # TUI for `git`
        libnotify # Send desktop notifications
        man-pages
        man-pages-posix
        networkmanagerapplet
        nmap # Map the network
        openconnect # Connect to VPNs
        pavucontrol # Pipewire sound control
        pipewire
        playerctl
        rename # Perl rename
        ripgrep # Modern `grep`
        rofi # Pop up menus
        rsync # Sync drives
        sd # sed alternative
        unzip
        waybar # Status bar
        wl-clipboard # Manage clipboard on wayland
        wpaperd
        xwayland-satellite # Run X applications
        zoxide # A better `cd`
      ]);

    variables = {
      SUDO_EDITOR = "nvim";
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
      TERM = "kitty";
      TERMINAL = "kitty.desktop";
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };
  };
}
