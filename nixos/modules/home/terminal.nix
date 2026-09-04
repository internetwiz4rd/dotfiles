{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages."${pkgs.stdenv.system}";
in
{
  options = {
    terminal.enable = lib.mkEnableOption "My terminal preferences";
  };

  config = lib.mkIf config.terminal.enable {
    home = {
      shell = {
        enableZshIntegration = true;
      };

      shellAliases = {
        c = "clear";
        icat = "kitten icat";
        l = "eza -a --sort=type --group-directories-first";
        ls = "eza";
        v = "nvim";
      };
    };

    programs = {
      bat.enable = true;

      zsh = {
        enable = true;
        package = pkgsUnstable.zsh;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        oh-my-zsh = {
          enable = true;
        };

        initContent = builtins.readFile ./../../../.zshrc;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      eza = {
        enable = true;
        enableZshIntegration = true;
        git = true;
        icons = "auto";
        colors = "auto";
      };

      kitty = {
        enable = true;
        shellIntegration.enableZshIntegration = true;
        enableGitIntegration = true;
      };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        silent = true;
      };

      newsboat = {
        enable = true;
        autoReload = true;
        urls = (fromTOML (builtins.readFile ./../../../feeds.toml)).feeds;
        extraConfig = builtins.readFile ../../../.config/newsboat/config;
      };
    };
  };
}
