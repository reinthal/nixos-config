# Root-owned deploy checkout of this repo at /etc/nixos-config, on every NixOS
# host (imported by minimal.nix, and by relay directly).
#
# Both deploy paths build from this checkout, never from ~/nixos-config:
#   - nixos-upgrade.service (system.autoUpgrade, unattended)
#   - `switch` (attended, one sudo prompt)
# The checkout only moves forward along origin/flaked, and only over commits
# signed with the YubiKey (see `verify` below). Pushing needs nothing but a
# GitHub credential, which any box (or a stolen token) can have; deploying
# needs a physical touch. A bad push makes the sync fail closed: nothing is
# built and the machine stays on the last verified commit. ~/nixos-config stays
# the place you edit, sign-commit and push from.
{
  config,
  lib,
  pkgs,
  ...
}: let
  dir = "/etc/nixos-config";
  remote = "https://github.com/reinthal/nixos-config";
  branch = "flaked";
  git = "${pkgs.git}/bin/git";

  # Deploy gate: only commits signed by one of these keys are deployed, so a
  # plain push from a box with GitHub credentials is fetched but never checked
  # out. Rotating a key needs a commit signed by a currently trusted one.
  #   - kog: YubiKey-held subkeys (local commits)
  #   - GitHub web-flow: commits made through the GitHub API/web UI, i.e. CI
  #     (update-flake.yml). Trusting it makes GitHub a single point of failure,
  #     accepted for now. Source: https://github.com/web-flow.gpg
  signingKeys = [
    ../../home-manager/gpg/pubkey.asc
    ../keys/github-web-flow.asc
  ];
  signingFprs = [
    "32B0D703BA943C3949E795B51B24ADB218CFB40E" # kog
    "968479A1AFF927E37D1A566BB5690EEEBB952194" # GitHub web-flow
  ];

  sync = pkgs.writeShellScript "nixos-config-sync" ''
    set -euo pipefail
    export GNUPGHOME=$(mktemp -d)
    trap 'rm -rf "$GNUPGHOME"' EXIT
    ${pkgs.gnupg}/bin/gpg --batch --quiet --import ${toString signingKeys}
    g() { ${git} -c gpg.program=${pkgs.gnupg}/bin/gpg -C ${dir} "$@"; }
    # %G? is G (good, trusted) or U (good, unknown trust: the throwaway
    # keyring has no trust db); %GP is the primary key of the signing subkey.
    verify() {
      case "$(g log -1 --format='%G?:%GP' "$1")" in
        ${lib.concatMapStringsSep " | " (f: "G:${f} | U:${f}") signingFprs}) ;;
        *)
          echo "nixos-config-sync: REFUSING $(g log -1 --format='%h %an: %s' "$1") — not signed by a trusted key" >&2
          exit 1
          ;;
      esac
    }

    if [ ! -d ${dir}/.git ]; then
      ${git} clone --no-checkout --branch ${branch} ${remote} ${dir}
      verify origin/${branch}
      g reset --hard origin/${branch}
    fi
    g fetch origin ${branch}
    OLD=$(g rev-parse HEAD)
    NEW=$(g rev-parse origin/${branch})
    if [ "$OLD" != "$NEW" ]; then
      if ! g merge-base --is-ancestor "$OLD" "$NEW"; then
        echo "nixos-config-sync: REFUSING origin/${branch}: history rewritten (not a descendant of $OLD)" >&2
        exit 1
      fi
      # Every first-parent commit since the last deploy must be signed, so an
      # unsigned commit can't ride in under a later signed one. Side branches
      # of a signed merge are vouched for by that merge.
      for c in $(g rev-list --first-parent "$OLD..$NEW"); do
        verify "$c"
      done
      g reset --hard "$NEW"
    fi
    g clean -fdx
    echo "nixos-config-sync: ${dir} at $(g log -1 --format='%h %s')"
  '';

  switch = pkgs.writeShellScriptBin "switch" ''
    set -euo pipefail
    FF_BKP=$HOME/.mozilla/firefox/default/search.json.mozlz4.hm-bkp
    if [ -f "$FF_BKP" ]; then
      rm "$FF_BKP"
    fi
    # Warn (don't block) when the local tree has work that won't be deployed.
    SRC=$HOME/nixos-config
    if [ -d "$SRC/.git" ]; then
      if [ -n "$(${git} -C "$SRC" status --porcelain)" ]; then
        echo "switch: warning: $SRC has uncommitted changes (not deployed)" >&2
      fi
      ${git} -C "$SRC" fetch --quiet origin ${branch} || true
      AHEAD=$(${git} -C "$SRC" rev-list --count origin/${branch}..HEAD 2>/dev/null || echo 0)
      if [ "$AHEAD" != 0 ]; then
        echo "switch: warning: $SRC is $AHEAD commit(s) ahead of origin/${branch} — push first to deploy them" >&2
      fi
    fi
    sudo systemctl start nixos-config-sync.service
    echo "switch: deploying $(${git} -c safe.directory=${dir} -C ${dir} log -1 --format='%h %s')"
    sudo nixos-rebuild switch --flake ${dir}#$(${pkgs.hostname}/bin/hostname)
  '';
in {
  systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

  systemd.services.nixos-config-sync = {
    description = "Sync ${dir} to origin/${branch}";
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = sync;
    };
  };

  system.autoUpgrade.flake = dir;
  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    requires = ["nixos-config-sync.service"];
    after = ["nixos-config-sync.service"];
  };

  environment.systemPackages = [switch];
}
