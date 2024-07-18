{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Don"t change this when you change package input. Leave it alone.
  home = {
    stateVersion = "24.05";
    # specify my home-manager configs
    packages = with pkgs; [
      # cli
      ripgrep
      thefuck
      jq
      just
      azure-cli
      fd
      curl
      less
      wget
      # data
      minio-client
      # crypto / identity
      yubikey-manager
      yubikey-manager-qt
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-touch-detector
      yubico-piv-tool
      yubioath-flutter
      pinentry-gnome3
      # dev
      poetry
      ruff
      # dev nix
      nixpkgs-fmt
      # devops
      terraform
      fluxcd
      kubeseal
      kustomize
      kubeconform
      kubectl
      k9s
      # coms
      signal-desktop
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      KEYID = "1B24ADB218CFB40E";
    };
  };
  programs.git = {
    enable = true;
    userEmail = "email@reinthal.me";
    userName = "Alexander Reinthal";
    signing = {
      signByDefault = true;
      key = "1B24ADB218CFB40E";
    };
  };
  programs.direnv.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry.gnome3;
    enableZshIntegration = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    extraConfig = ''ttyname $GPG_TTY'';
  };
  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      # Default preferences for new keys
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      # SHA512 as digest to sign keys
      cert-digest-algo = "SHA512";
      # SHA512 as digest for symmetric ops
      s2k-digest-algo = "SHA512";
      # AES256 as cipher for symmetric ops
      s2k-cipher-algo = "AES256";
      # UTF-8 support for compatibility
      charset = "utf-8";
      # No comments in messages
      no-comments = true;
      # No version in output
      no-emit-version = true;
      # Disable banner
      no-greeting = true;
      # Long key id format
      keyid-format = "0xlong";
      # Display UID validity
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      # Display all keys and their fingerprints
      with-fingerprint = true;
      # Display key origins and updates
      #with-key-origin
      # Cross-certify subkeys are present and valid
      require-cross-certification = true;
      # Disable caching of passphrase for symmetrical ops
      no-symkey-cache = true;
      # Output ASCII instead of binary
      armor = true;
      # Enable smartcard
      use-agent = true;
      # Disable recipient key ID in messages (breaks Mailvelope)
      throw-keyids = true;
    };
    scdaemonSettings = {
      disable-ccid = true;
    };
  };
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.eza.enable = true;
  programs.zsh.enable = true;
  programs.zsh.autocd = true;
  programs.zsh.history.share = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellAliases = {
    ls = "eza --color=auto -F";
    l = "eza -l --color=auto -F";
    nswitch = "nix run nix-darwin -- switch --flake ~/dotfiles";
    nup = "pushd ~/dotfiles; nix flake update; nswitch; popd";
    aztest = "az account set --subscription 216a725a-bbca-4c05-8ce2-fbd86f6e2776";
    azprod = "az account set --subscription 17bc8fef-0659-4163-8114-7a08357a586e";
    azprodbla = "az account set --subscription c00506ae-6992-4d21-939b-f285d4c5f35e";
    azdrivetdev = "az account set --subscription 56ed82a0-88f7-4dd4-9402-240515b36bfa";
    azdrivetprod = "az account set --subscription 33c6f479-ad1f-4f88-bcf4-fc66ba2cdb1f";
    g = "git";
    gs = "git status";
    gc = "git commit -m";
    gd = "git diff";
  };
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "FireCode Nerd Font Mono";
      font.size = 16;

      keyboard.bindings = [
        {
          key = "i";
          mods = "Control";
          action = "ToggleViMode";
        }
        {
          key = "h";
          # Move left
          mods = "Control";
          action = "WordLeft";
        }
        {
          key = "l";
          mods = "Control";
          # move right
          action = "WordRightEnd";
        }
      ];
    };
  };
  programs.firefox = {
    enable = true;
  };
  programs.kitty = {
    enable = true;
    font = {
      name = "FireCode Nerd Font Mono";
      size = 15;
    };
  };
  home.file.".inputrc".source = ./dotfiles/.inputrc;
}
