# Proton Meet desktop (not in nixpkgs). Repackaged from Proton's .deb the
# same way nixpkgs does proton-pass: keep only app.asar + resources and run it
# on nixpkgs' Electron instead of the bundled one.
#
# Version, hash and Electron major are pinned in ./proton-meet.json, bumped by
# scripts/update-proton-meet.sh (run daily by .github/workflows/update-flake.yml).
{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  makeWrapper,
  asar,
  pkgs,
}: let
  pin = lib.importJSON ./proton-meet.json;
  # The Electron major the .deb was built for. Missing from nixpkgs = eval
  # error, which keeps the CI update from committing.
  electron = pkgs."electron_${pin.electron}";
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "proton-meet";
    inherit (pin) version;

    src = fetchurl {
      url = "https://proton.me/download/meet/linux/${finalAttrs.version}/ProtonMeet-desktop.deb";
      inherit (pin) hash;
    };

    nativeBuildInputs = [
      dpkg
      makeWrapper
      asar
    ];

    dontConfigure = true;
    dontBuild = true;

    # process.resourcesPath would point into nixpkgs' electron; the app loads
    # loading.html / error-network.html from there. Hardcode our copy.
    preInstall = ''
      asar extract usr/lib/proton-meet/resources/app.asar tmp
      rm usr/lib/proton-meet/resources/app.asar
      substituteInPlace tmp/.webpack/main/index.js \
        --replace-fail "process.resourcesPath" "'$out/share/proton-meet'"
      asar pack tmp/ usr/lib/proton-meet/resources/app.asar
      rm -rf tmp
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/proton-meet
      cp -r usr/share/{applications,icons} $out/share/
      cp -r usr/lib/proton-meet/resources/* $out/share/proton-meet/
      runHook postInstall
    '';

    preFixup = ''
      makeWrapper ${lib.getExe electron} $out/bin/proton-meet \
        --add-flags $out/share/proton-meet/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0
    '';

    meta = {
      description = "Desktop application for Proton Meet";
      homepage = "https://proton.me/meet";
      license = lib.licenses.gpl3Plus;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      mainProgram = "proton-meet";
    };
  })
