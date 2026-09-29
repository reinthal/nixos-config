# Asahi Linux "fairydust" kernel: the upstream experimental branch that adds
# USB-C DisplayPort alt-mode output on Apple Silicon Macs.
#
# Mirrors the linux-asahi package from nixos-apple-silicon
# (apple-silicon-support/packages/linux-asahi/default.nix) with the source
# swapped for a pinned commit of https://github.com/AsahiLinux/linux/tree/fairydust.
# Keep `version` in sync with the VERSION/PATCHLEVEL/SUBLEVEL in that tree's
# Makefile, and bump `rev` + `hash` together.
#
# Caveats (upstream): developer preview, unsupported. One "blessed" USB-C port
# per machine (front-left on MacBooks), one external display over USB-C, and
# hot-plug can be flaky. See README.md "Asahi fairydust kernel".
{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [],
} @ args: let
  extraArgs = lib.removeAttrs args [
    "lib"
    "callPackage"
    "linuxPackagesFor"
    "_kernelPatches"
  ];

  linux-asahi-fairydust-pkg = {
    stdenv,
    lib,
    fetchFromGitHub,
    buildLinux,
    ...
  }:
    buildLinux (
      lib.recursiveUpdate rec {
        inherit stdenv lib;

        pname = "linux-asahi-fairydust";
        version = "7.1.13";
        modDirVersion = version;
        extraMeta.branch = "7.1";

        # fairydust branch head as of 2026-09-08 (12 commits on top of
        # asahi-7.1.13-2: DP alt-mode DTS hacks + tipd HPD tracking).
        src = fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
          hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
        };

        kernelPatches =
          [
            {
              name = "Asahi config";
              patch = null;
              # Identical to the stock nixos-apple-silicon config. The DP
              # alt-mode drivers (DRM_APPLE, PHY_APPLE_ATC, PHY_APPLE_DPTX,
              # TYPEC_TPS6598X, TYPEC_DP_ALTMODE) already build as modules via
              # nixpkgs' autoModules, so nothing extra is needed for fairydust.
              structuredExtraConfig = with lib.kernel; {
                # Needed for GPU
                ARM64_16K_PAGES = yes;

                ARM64_MEMORY_MODEL_CONTROL = yes;
                ARM64_ACTLR_STATE = yes;

                # Might lead to the machine rebooting if not loaded soon enough
                APPLE_WATCHDOG = yes;

                # Can not be built as a module, defaults to no
                APPLE_M1_CPU_PMU = yes;

                # Defaults to 'y', but we want to allow the user to set options in modprobe.d
                HID_APPLE = module;

                APPLE_PMGR_MISC = yes;
                APPLE_PMGR_PWRSTATE = yes;

                # Defaults to 'n', but needed to prevent bluetooth stuttering
                BT_BRCMEXT = yes;
              };
              features.rust = true;
            }
          ]
          ++ _kernelPatches;
      }
      extraArgs
    );

  linux-asahi-fairydust = callPackage linux-asahi-fairydust-pkg {};
in
  lib.recurseIntoAttrs (linuxPackagesFor linux-asahi-fairydust)
