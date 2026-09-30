# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}:
rec {
  custom-fonts = pkgs.callPackage ./fonts {};
  evilginx = pkgs.callPackage ./evilginx {};
  trim-screencast = pkgs.callPackage ./trim-screencast.nix {};
  setup-gpg-forward = pkgs.callPackage ./setup-gpg-forward.nix {};
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
# Asahi fairydust kernel only makes sense on aarch64-linux; guarding keeps
# `nix flake check`/`show` from evaluating a kernel on darwin/x86.
// pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-linux") {
  linux-asahi-fairydust = pkgs.callPackage ./linux-asahi-fairydust {};
}
