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
  services.podman = {
    enable = true;
    settings.containers = {
      # Enable Docker-compatible socket behavior
    };
  };

  # Podman user socket — needed for Traefik's docker.sock bind
  systemd.user.sockets.podman = {
    Unit.Description = "Podman API Socket (rootless)";
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install.WantedBy = ["sockets.target"];
  };

  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API Service (rootless)";
      Requires = ["podman.socket"];
      After = ["podman.socket"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
    };
  };
  home = {
    username = "claw";
    homeDirectory = "/home/claw";
    stateVersion = stateVersion;
    # specify my home-manager configs
    packages = with pkgs;
      [
        # cli
        bun
        age
        managarr
        vdirsyncer
        khal
        nodejs_24
        tdf
        uv
        mcp-nixos
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
        # programming
        gh
        # data
        # dev nix
        chromium
      ]
      ++ [
        pkgs.unstable.codex
        pkgs.unstable.claude-code
        pkgs.unstable.devenv
      ];
    sessionPath = [
      "$HOME/.npm-global/bin"
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
      EDITOR = "nvim";
      KEYID = "1B24ADB218CFB40E";
      SHELL = "${pkgs.zsh}/bin/zsh";
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
      userName = "minime (alex bot)";
      userEmail = "minime@reinthal.me";
      signing = {
        signByDefault = false;
        key = "";
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
  };
}
