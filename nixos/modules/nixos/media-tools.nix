{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

in
{
  options = {
    modules.media-tools.enable = lib.mkEnableOption "Enable media tools";
    modules.media-tools.extra.enable = lib.mkEnableOption "Enables extra media tools";
  };

  config = lib.mkIf config.modules.media-tools.enable {
    environment.systemPackages =
      (with pkgs; [
        dvgrab # DV Camcorder Video Capture
        ffmpeg # Video format transcription
        gimp # Image editor
        kdePackages.kdenlive # Video editor
        kid3 # Audio tagger
        krita # Drawing program
        musescore # Score writing tool
        qimgv # Qt6 image viewer
      ])
      ++ (with pkgsUnstable; [
        # vcv-rack # Modular synthesizers
        audacity # Audio editor
        yt-dlp # YouTube downloader
      ]);

    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;

      plugins = with pkgs.obs-studio-plugins; [
        droidcam-obs
        obs-backgroundremoval
        obs-gstreamer
        obs-pipewire-audio-capture
        obs-vaapi
        obs-vkcapture
        wlrobs
      ];
    };

    #   environment.systemPackages =
    #     (with pkgs; [
    #       audacity # Audio editor
    #       ffmpeg # Video format transcription
    #       qimgv # Qt6 image viewer
    #       gimp # Image editor
    #     ])
    #     ++ (with pkgsUnstable; [
    #       yt-dlp # YouTube downloader
    #       krita # Drawing program
    #     ])
    #     ++ lib.optionals config.modules.media-tools.extra.enable (
    #       (with pkgs; [
    #         blender
    #         aseprite # Sprite drawing program
    #         cdrdao
    #         cdrtools
    #         droidcam
    #         dvgrab # DV Camcorder Video Capture
    #         handbrake
    #         inkscape
    #         kdePackages.kdenlive # Video editor
    #         vcv-rack # Modular synthesizers
    #         musescore # Score writing tool
    #       ])
    #       ++ (with pkgsUnstable; [
    #         kdePackages.k3b # CD and DVD manager
    #       ])
    #     );
    # }
    # // lib.mkIf config.modules.media-tools.extra.enable {
    #   programs.obs-studio = {
    #     enable = true;
    #     enableVirtualCamera = true;
    #
    #     plugins = with pkgs.obs-studio-plugins; [
    #       droidcam-obs
    #       obs-backgroundremoval
    #       obs-gstreamer
    #       obs-pipewire-audio-capture
    #       obs-vaapi
    #       obs-vkcapture
    #       wlrobs
    #     ];
    #   };
    #
    #   security.wrappers = {
    #     cdrdao = {
    #       setuid = true;
    #       owner = "root";
    #       group = "cdrom";
    #       permissions = "u+wrx,g+x";
    #       source = "${pkgs.cdrdao}/bin/cdrdao";
    #     };
    #     cdrecord = {
    #       setuid = true;
    #       owner = "root";
    #       group = "cdrom";
    #       permissions = "u+wrx,g+x";
    #       source = "${pkgs.cdrtools}/bin/cdrecord";
    #     };
    #   };
  };
}
