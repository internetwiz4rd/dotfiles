{
  config,
  pkgs,
  inputs,
  username,
  ...
}:
{
  # Adds each spell in my spellbook to PATH as a derivation with a binary :]
  # Gosh do I love the fact that Nix is a whole functional language too
  # I love functional programming
  home.packages = builtins.attrValues (
    let
      spellbookPath = ./../../../spellbook;
    in
    pkgs.lib.mapAttrs'
      (
        # Evaluates to a list of name and value pairs that then get passed to mapAttrs'
        # to then get turned into an attribute set
        name: value:
        # Maps the name of the file to a camelCase version without the file suffix
        pkgs.lib.nameValuePair (pkgs.lib.toCamelCase (pkgs.lib.removeSuffix ".sh" name))
          # Returns a derivation with a binary that's the name of the script without the extension
          # and the content is the script itself
          (
            pkgs.writeShellScriptBin (pkgs.lib.removeSuffix ".sh" name) (
              builtins.readFile (spellbookPath + ("/" + name))
            )
          )
      )
      # Returns an attribute set with only the `.sh` files as the names of the values
      (pkgs.lib.filterAttrs (name: type: pkgs.lib.hasSuffix ".sh" name) (builtins.readDir spellbookPath))
  );

  # Iterates through the ".config" directory in the root of the repo and lets home manager make symlinks to them
  xdg.configFile =
    let
      configPath = ./../../../.config;
    in
    pkgs.lib.mapAttrs
      (
        # For each file name, it sets its value to the attribute set containing its source as being the
        # configPath + the file's name
        name: value: { source = configPath + ("/" + name); })
      (
        # Returns an attribute set with all non-backup files as the names and what kind of file they are as
        # the value
        pkgs.lib.filterAttrs (name: type: !(pkgs.lib.hasSuffix ".bak" name)) (builtins.readDir configPath)
      );

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

    file = {
      ".gitconfig".source = ./../../../.gitconfig;
      ".secrets".source = ./../../../.secrets;
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "26.05"; # Please read the comment before changing.
  };

  programs = {
    bat.enable = true;

    zsh = {
      enable = true;
      package = pkgs.zsh;
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
  };
}
