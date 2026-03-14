# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}: rec {
  custom-fonts = pkgs.callPackage ./fonts {};
  ferroxide = pkgs.callPackage ./ferroxide.nix {};
  trim-screencast = pkgs.callPackage ./trim-screencast.nix {};
  hyprland-keybindings-menu = pkgs.callPackage ./hyprland-keybindings-menu.nix {};
  wrapWine = pkgs.callPackage ./wrapWine.nix {};
  kindle_1_17 = pkgs.callPackage ./wineApps/kindle.nix {
    inherit wrapWine;
  };
}
