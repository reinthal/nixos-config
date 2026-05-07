{
  pkgs,
  inputs,
  stateVersion,
  config,
  ...
}: let
  reinthalVim = inputs.reinthalVim.packages.${pkgs.system}.default;
  configDirectory = config.xdg.configHome;
  anthropicKey = "${configDirectory}/Claude/api.key";
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
        nodejs_24
        bun
        tidal-dl
        wireguard-tools
        uv
        mcp-nixos
        fd
        dig
        sops
        tree
        nmap
        tcpdump
        reinthalVim
        ripgrep
        tldr
        jq
        tree
        yq
        curl
        less
        wget
        lazygit
        git-lfs
        btop
        tree
        inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
        # programming
        gh
        nixd
        # dev nix
        nixpkgs-fmt
        claude-code
      ]
      ++ [
        pkgs.unstable.signal-desktop
        pkgs.unstable.claude-code
        pkgs.unstable.mcp-proxy
        pkgs.unstable.devenv
      ];
    sessionPath = [
      "$HOME/.npm-global/bin"
      "$HOME/.cache/.bun/bin"
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
