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
        ngrok
        fd
        dig
        lftp
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
        yt-dlp
        svtplay-dl
        inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
        # programming
        gh
        nodejs
        pyright
        devenv
        nixd
        # data
        minio-client
        # dev
        ruff
        # dev nix
        nixpkgs-fmt
        # devops
        k9s
        kubectl
      ]
      ++ [
        pkgs.unstable.signal-desktop
        pkgs.unstable.claude-code
        pkgs.unstable.mcp-proxy
      ];

    sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
      EDITOR = "nvim";
      KEYID = "1B24ADB218CFB40E";
      ANTHROPIC_API_KEY = builtins.readFile anthropicKey;
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
      userEmail = "email@reinthal.me";
      userName = "Alexander Reinthal";
      signing = {
        signByDefault = true;
        key = "1B24ADB218CFB40E";
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
        whitelist.prefix = [
          "~/repos/portgot/"
        ];
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
      history.share = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "eza --color=auto -F";
        l = "eza -l --color=auto -F";
        nswitch = "nix run nix-darwin -- switch --flake ~/nixos-config --impure";
        nup = "pushd ~/nixos-config; nix flake update; nswitch; popd";
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
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
