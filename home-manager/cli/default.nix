{
  pkgs,
  inputs,
  stateVersion,
  config,
  ...
}: let
  reinthalVim = inputs.reinthalVim.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [../scripts/cache-upload.nix];

  xdg = {
    configFile."distrobox/distrobox.conf".source = ../dotfiles/distrobox.conf;
    configFile."opencode/.opencode.json".source = ../dotfiles/.opencode.json;
  };

  home = {
    file.".inputrc".source = ../dotfiles/.inputrc;

    stateVersion = stateVersion;
    # specify my home-manager configs
    packages = with pkgs;
      [
        # cli
        # cyberstrike: nixpkgs package broken; installed via bun in
        # scripts/bootstrap-home-manager.sh (bun add -g @cyberstrike-io/cyberstrike)
        nodejs_24
        bun
        wireguard-tools
        uv
        fd
        dig
        sops
        tree
        nmap
        tcpdump
        reinthalVim
        ripgrep
        jq
        tree
        yq
        curl
        less
        lazygit
        git-lfs
        btop
        tree
        inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
        # programming
        gh
        forgejo-cli
        nixpkgs-fmt
      ]
      ++ [
        pkgs.unstable.signal-desktop
        pkgs.unstable.claude-code
        pkgs.unstable.devenv
      ];
    sessionPath = [
      "$HOME/.npm-global/bin"
      "$HOME/.cache/.bun/bin"
      "$HOME/.bun/bin" # bun global installs (e.g. cyberstrike)
    ];
    sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
      EDITOR = "nvim";
      KEYID = "1B24ADB218CFB40E";
      SHELL = "${pkgs.zsh}/bin/zsh";
      # Fix SSL certificate path for uv and other tools expecting OpenSSL default location
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
  };

  programs = {
    tmux = {
      enable = true;
      mouse = true;
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          email = "email@reinthal.me";
          name = "Alexander Reinthal";
        };
      };
      signing = {
        signByDefault = true;
        key = "1B24ADB218CFB40E";
        format = "openpgp";
      };
    };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    direnv = {
      enable = true;
      config = {
        global.load_dotenv = true;
      };
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;

    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      # Standalone (non-NixOS) single-user Nix: the installer only wires PATH
      # into ~/.profile, which zsh login shells never read. Source the profile
      # script from .zshenv (sourced by every zsh, incl. login) so
      # ~/.nix-profile/bin (eza, ripgrep, all HM packages) lands on PATH.
      # No-op on NixOS hosts, where PATH already includes the profile.
      envExtra = ''
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';
      # Word motion on ctrl/alt+arrows (xterm CSI 1;5 / 1;3 sequences, which
      # ghostty sends). Ctrl+Backspace (^H in ghostty) / Ctrl+Delete kill words.
      # Zsh defaults to the vi insert keymap here (EDITOR=nvim), bind in both.
      initContent = ''
        for m in viins emacs; do
          bindkey -M $m "^[[1;5D" backward-word
          bindkey -M $m "^[[1;5C" forward-word
          bindkey -M $m "^[[1;3D" backward-word
          bindkey -M $m "^[[1;3C" forward-word
          bindkey -M $m "^H" backward-kill-word
          bindkey -M $m "^[[3;5~" kill-word
        done
        # Treat / and - as word boundaries so jumps stop at path segments.
        WORDCHARS='*?_.[]~=&;!#$%^(){}<>'
      '';
      autocd = true;
      history = {
        share = true;
        append = true;
      };
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ls = "eza --color=auto -F";
        l = "eza -l --color=auto -F";
        g = "git";
        gs = "git status";
        gc = "git commit -m";
        gd = "git diff";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    khal = {
      enable = true;
      locale = {
        timeformat = "%H:%M";
        dateformat = "%Y-%m-%d";
        longdateformat = "%Y-%m-%d";
        datetimeformat = "%Y-%m-%d %H:%M";
        longdatetimeformat = "%Y-%m-%d %H:%M";
      };
    };
  };
}
