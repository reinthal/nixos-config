# Minimal CLI home-manager config for the "seek" host.
# Just enough to get around: shell, prompt, and a handful of utilities.
# No git/gh, no coding tools, no secrets.
{
  pkgs,
  outputs,
  ...
}: {
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable-packages
      outputs.overlays.master-packages
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      wget
      curl
      jq
      just
      fd
      ripgrep
      tree
      btop
      less
    ];
    sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
    };
  };

  programs = {
    eza.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

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
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
