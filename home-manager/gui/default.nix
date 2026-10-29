# GUI for the shared hosts (workstation, build, nixbook): base apps plus
# PWA/third-party chat clients and LibreOffice. framebook uses
# ../framebook.nix with native clients instead.
{
  lib,
  pkgs,
  ...
}: {
  imports = [./base.nix];

  home.packages = with pkgs;
    [
      vesktop
      slacky
      libreoffice-qt6-fresh
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [pkgs.slack pkgs.discord];
}
