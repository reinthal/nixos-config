# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}: rec {
  custom-fonts = pkgs.callPackage ./fonts {};
  trim-screencast = pkgs.callPackage ./trim-screencast.nix {};
  hyprland-keybindings-menu = pkgs.callPackage ./hyprland-keybindings-menu.nix {};
  timer-bar = pkgs.callPackage ./timer-bar.nix {
    workMinutes = 30;
    restMinutes = 10;
  };
  wrapWine = pkgs.callPackage ./wrapWine.nix {};
  kindle_1_17 = pkgs.callPackage ./wineApps/kindle.nix {
    inherit wrapWine;
  };
}
