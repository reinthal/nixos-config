# Home-manager config for framebook (Framework laptop, Hyprland).
#
# Same base as ./default.nix, except:
#   - native clients instead of PWAs / third-party clients:
#     Slack, Discord, Proton Mail (+ Calendar), Proton Pass, Proton VPN,
#     Proton Authenticator
#   - no LibreOffice
#   - native Spotify instead of the spotify-player TUI/daemon
#   - gpg-agent comes from home-manager (drduh setup, ./gpg/agent.nix)
#   - hyprlock with fingerprint unlock + hypridle auto-lock
#   - Electron apps keep their secrets in gnome-keyring
{
  lib,
  pkgs,
  outputs,
  stateVersion,
  ...
}: let
  # Under Hyprland, Chromium/Electron can't detect a keyring from
  # XDG_CURRENT_DESKTOP and fall back to the "basic" store, which keeps
  # session tokens on disk in plaintext. Force the libsecret
  # (gnome-keyring) backend.
  passwordStoreFlag = "--password-store=gnome-libsecret";
  withKeyring = pkg:
    pkgs.symlinkJoin {
      name = "${pkg.pname or pkg.name}-keyring";
      paths = [pkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for b in $out/bin/*; do
          wrapProgram "$b" --add-flags ${passwordStoreFlag}
        done
        # .desktop files point at the unwrapped binary; repoint them.
        # (share/applications may itself be a read-only symlink: rebuild it)
        if [ -d ${pkg}/share/applications ]; then
          if [ -L $out/share ]; then
            t=$(readlink -f $out/share)
            rm $out/share
            mkdir $out/share
            ln -s $t/* $out/share/
          fi
          rm -rf $out/share/applications
          mkdir -p $out/share/applications
          for d in ${pkg}/share/applications/*.desktop; do
            sed "s|${pkg}/bin/|$out/bin/|g" "$d" > "$out/share/applications/$(basename "$d")"
          done
        fi
      '';
      inherit (pkg) meta;
    };

  slack = withKeyring pkgs.slack;
  discord = withKeyring pkgs.discord;
  proton-mail = withKeyring pkgs.protonmail-desktop;
  proton-pass = withKeyring pkgs.proton-pass;
in {
  imports = [
    ./gpg
    ./gpg/agent.nix
    ./cli
    ./email
    ./terminal
    ./yubikey
    ./scripts
    ./hyprland
    ./theme.nix
    ./sops.nix
    ./gui/base.nix
  ];

  # gnome-keyring is started by PAM at the ReGreet login (nixos regreet.nix)
  # and unlocked with the login password. Don't run a second daemon here.

  home.packages = [
    slack
    discord
    proton-mail
    proton-pass
    pkgs.proton-vpn
    pkgs.proton-authenticator
  ];

  programs.chromium.commandLineArgs = [passwordStoreFlag];

  local.hyprland = {
    scratchpads = {
      slack = "slack";
      discord = "discord";
      # Proton Mail desktop also contains Calendar (switch from the app).
      email = "proton-mail";
      calendar = "proton-mail";
    };
    locker = "hyprlock";
    # Native Spotify client (gui/base.nix) instead of spotify-player.
    spotifyPlayerBinds = false;
  };

  # Fingerprint is read by hyprlock itself (fprintd over D-Bus), in parallel
  # with the password field. PAM's fprintd is off for hyprlock on the NixOS
  # side so the two don't race.
  xdg.configFile."hypr/hyprlock.conf".text = lib.mkAfter ''
    auth {
        pam:enabled = true
        fingerprint:enabled = true
        fingerprint:ready_message = Scan fingerprint to unlock
        fingerprint:present_message = Scanning...
    }
  '';

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
  # Same guard as wayle / hyprctl-reload: GNOME brings its own idle + lock.
  systemd.user.services.hypridle.Unit.ConditionEnvironment = lib.mkForce [
    "WAYLAND_DISPLAY"
    "!XDG_CURRENT_DESKTOP=GNOME"
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable-packages
      outputs.overlays.master-packages
      outputs.overlays.modifications
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Don"t change this when you change package input. Leave it alone.
  home = {
    stateVersion = stateVersion;
  };
}
