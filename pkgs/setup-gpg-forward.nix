# One-shot setup for gpg-agent forwarding over SSH.
#
# Run from the machine holding the Yubikey (e.g. nixbook). Makes a remote host
# sign/decrypt with THIS machine's key over a forwarded agent socket:
#   - local:  launch gpg-agent, confirm the restricted "extra" socket exists
#   - remote: enable sshd StreamLocalBindUnlink (so the forwarded socket can
#             replace a stale one), import the public key, mark it trusted
#   - verify: sign a test message through the forwarded agent
#
# The RemoteForward itself is declared in the ssh config
# (home-manager/gpg/forward-gpg-agent.nix); this only does the imperative
# bits that can't live in Nix (remote sudo, key import/trust, verification).
#
# Requires passwordless sudo on the remote (the sshd step runs over a
# non-interactive ssh session).
{
  writeShellApplication,
  openssh,
  gnupg,
  gawk,
  coreutils,
  git,
}:
writeShellApplication {
  name = "setup-gpg-forward";
  runtimeInputs = [openssh gnupg gawk coreutils git];
  text = ''
    REMOTE="''${1:-}"
    KEY="''${2:-''${GPG_KEY:-$(git config --global user.signingkey 2>/dev/null || true)}}"

    if [[ -z "$REMOTE" || -z "$KEY" ]]; then
      cat >&2 <<'USAGE'
usage: setup-gpg-forward <user@host> [gpg-key-id-or-email]

Enables gpg-agent forwarding so <user@host> signs with this machine's key.
KEY defaults to git's user.signingkey, then $GPG_KEY.
Needs passwordless sudo on the remote.
USAGE
      exit 2
    fi

    echo ">> local: launch gpg-agent, check restricted extra socket"
    gpgconf --launch gpg-agent
    extra="$(gpgconf --list-dirs agent-extra-socket)"
    [[ -S "$extra" ]] || {
      echo "no gpg-agent extra socket at $extra" >&2
      exit 1
    }

    echo ">> remote: enable sshd StreamLocalBindUnlink (passwordless sudo required)"
    ssh -o ClearAllForwardings=yes "$REMOTE" sudo bash -s <<'REMOTE'
set -eu
cfg=/etc/ssh/sshd_config
if [ -d /etc/ssh/sshd_config.d ] && grep -qE '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/' "$cfg"; then
  printf 'StreamLocalBindUnlink yes\n' > /etc/ssh/sshd_config.d/10-gpg-forward.conf
else
  grep -qxF 'StreamLocalBindUnlink yes' "$cfg" || printf 'StreamLocalBindUnlink yes\n' >> "$cfg"
fi
sshd -t
systemctl reload ssh 2>/dev/null \
  || systemctl reload sshd 2>/dev/null \
  || service ssh reload 2>/dev/null \
  || kill -HUP "$(cat /run/sshd.pid 2>/dev/null || pgrep -x sshd | head -1)"
REMOTE

    echo ">> remote: import public key + mark ultimately trusted"
    fpr="$(gpg --with-colons --fingerprint "$KEY" | awk -F: '/^fpr:/{print $10; exit}')"
    gpg --export "$KEY" | ssh -o ClearAllForwardings=yes "$REMOTE" gpg --import
    # $fpr must expand here (client side), not on the remote — that's the point.
    # shellcheck disable=SC2029
    ssh -o ClearAllForwardings=yes "$REMOTE" "printf '%s:6:\n' '$fpr' | gpg --import-ownertrust"

    echo ">> verify: sign through the forwarded agent (touch the Yubikey if prompted)"
    # shellcheck disable=SC2029
    if ssh "$REMOTE" "gpgconf --kill gpg-agent >/dev/null 2>&1; printf 'forward-ok\n' | gpg --clearsign -u '$KEY'" \
      | grep -q 'BEGIN PGP SIGNED MESSAGE'; then
      echo "OK: remote signs with this machine's key over the forwarded agent."
    else
      echo "FAILED: remote could not sign. Check the ssh config RemoteForward" >&2
      echo "and that the Yubikey is present on this machine." >&2
      exit 1
    fi
  '';
}
