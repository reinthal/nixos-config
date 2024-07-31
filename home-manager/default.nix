{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}: 
{
  imports = [
    ./crypto
    ./cli
    ./waybar
    ./hyprlock.nix
    ./hyprland.nix
    ./theme.nix
     (import ./gui {inherit lib pkgs;})
  ];
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
    packages = with pkgs; [];
  };
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
