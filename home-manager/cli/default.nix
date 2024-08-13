{pkgs, ...}: {
  home = {
    file.".inputrc".source = ./dotfiles/.inputrc;
    stateVersion = "24.05";

    # specify my home-manager configs
    packages = with pkgs; [
      # cli
      ripgrep
      thefuck
      jq
      just
      azure-cli
      curl
      less
      wget
      lazygit
      btop

      # data
      minio-client

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
    ];

    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      KEYID = "1B24ADB218CFB40E";
    };
  };

  programs = {
    git = {
      enable = true;
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
