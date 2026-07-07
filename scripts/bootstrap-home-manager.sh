#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a Linux (Ubuntu/Debian) host with Nix + Home Manager and this repo's CLI config.
#
# Uses single-user (no-daemon) Nix so it works in containers (Docker/Kubernetes)
# without systemd. Nix is owned by the invoking user; config lives in
# ~/.config/nix/nix.conf. Runs as root (common in containers) or as an
# unprivileged user with sudo.

# Pick a privilege-escalation prefix: nothing when root, sudo otherwise.
if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  SUDO=""
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required when not running as root." >&2
    exit 1
  fi
  SUDO="sudo"
fi

REPO_DIR_DEFAULT="$HOME/nixos-config"
REPO_DIR="${REPO_DIR:-$REPO_DIR_DEFAULT}"
REPO_URL="${REPO_URL:-https://github.com/reinthal/nixos-config}"

# Append a line to a user-owned file if not already present.
ensure_line() {
  local line="$1" file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >>"$file"
}

# Base packages
$SUDO apt update
$SUDO apt install -y curl git gh vim zsh

# Install Nix (single-user / no-daemon mode; no systemd required)
if ! command -v nix >/dev/null 2>&1; then
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
  # Make Nix available in this shell without a new login.
  if [[ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
fi

# Configure Nix per-user (single-user mode has no daemon; the user is trusted,
# so substituters/keys go straight into the user config).
NIX_CONF="$HOME/.config/nix/nix.conf"
ensure_line "experimental-features = nix-command flakes" "$NIX_CONF"
ensure_line "extra-substituters = https://devenv.cachix.org" "$NIX_CONF"
ensure_line "extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= reinthal-cache.cachix.org-1:wFPDVH/makS72ZY3Y8jA0BehXDBhQ3syqo0UJu7oah8=" "$NIX_CONF"

# Install Home Manager via channels (bootstrap)
if ! command -v home-manager >/dev/null 2>&1; then
  nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
fi

# Clone repo if missing
if [[ ! -d "$REPO_DIR" ]]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# Detect if running on a Lambda GPU server (Ubuntu with NVIDIA/CUDA)
IS_LAMBDA=false
if [[ -d /usr/local/cuda ]] && command -v nvidia-smi >/dev/null 2>&1; then
  IS_LAMBDA=true
fi

# Symlink only NVIDIA/CUDA driver libs into /run/opengl-driver/lib.
# Nix tools expect driver libs at /run/opengl-driver/lib but symlinking the
# entire /usr/lib/x86_64-linux-gnu causes glibc conflicts with Nix's own glibc.
if [[ "$IS_LAMBDA" == true ]]; then
  $SUDO mkdir -p /run/opengl-driver/lib
  for lib in libcuda.so libcuda.so.1 libnvidia-ml.so.1 libnvidia-ml.so \
             libcudadebugger.so.1 libnvidia-ptxjitcompiler.so.1 \
             libnvidia-nvvm.so.4 libnvidia-gpucomp.so; do
    src="/usr/lib/x86_64-linux-gnu/$lib"
    if [[ -e "$src" ]]; then
      $SUDO ln -sfn "$src" "/run/opengl-driver/lib/$lib"
    fi
  done
  echo "Symlinked NVIDIA/CUDA driver libs into /run/opengl-driver/lib/"
fi

# Allow a client (e.g. nixbook) to forward its Yubikey gpg-agent socket onto
# this host's standard agent path: sshd must unlink a stale forwarded socket
# before binding. Mirrors services.openssh.settings.StreamLocalBindUnlink used
# on the NixOS hosts. Best-effort — skipped when there's no sshd (containers).
if [[ -d /etc/ssh/sshd_config.d ]]; then
  printf 'StreamLocalBindUnlink yes\n' \
    | $SUDO tee /etc/ssh/sshd_config.d/10-gpg-forward.conf >/dev/null
  $SUDO systemctl reload ssh 2>/dev/null \
    || $SUDO systemctl reload sshd 2>/dev/null \
    || true
  echo "Enabled StreamLocalBindUnlink for gpg-agent forwarding."
fi

# Choose flake config. Priority: explicit env override > known hostname >
# arch + GPU-host heuristic. FLAKE_CONFIG can be set to force any config.
ARCH=$(uname -m)
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"

if [[ -n "${FLAKE_CONFIG:-}" ]]; then
  : # honor caller-provided value
else
  case "$HOSTNAME_SHORT" in
    gpaulo-ord-0)
      # 8x A40 GPU cluster node
      FLAKE_CONFIG="alexander@gpaulo-ord-0"
      ;;
    *)
      case "$ARCH" in
        x86_64)
          if [[ "$IS_LAMBDA" == true ]]; then
            FLAKE_CONFIG="ubuntu@lambda"
          else
            FLAKE_CONFIG="kog@cli"
          fi
          ;;
        aarch64|arm64)
          if [[ "$IS_LAMBDA" == true ]]; then
            FLAKE_CONFIG="ubuntu@lambda"
          else
            FLAKE_CONFIG="kog@cli-aarch64"
          fi
          ;;
        *)
          echo "Unsupported architecture: $ARCH" >&2
          exit 1
          ;;
      esac
      ;;
  esac
fi

echo "Detected architecture: $ARCH, using flake config: $FLAKE_CONFIG"

# Install the CLI home-manager config
home-manager switch --flake ".#$FLAKE_CONFIG" --impure -b bkp

# Register zsh as a valid login shell and set it as default. Best-effort:
# containers may lack /etc/shells write access or a working chsh.
ZSH_BIN="$(command -v zsh)"
$SUDO sh -c "grep -qxF '$ZSH_BIN' /etc/shells 2>/dev/null || echo '$ZSH_BIN' >>/etc/shells" || true
$SUDO sh -c "grep -qxF '$HOME/.nix-profile/bin/zsh' /etc/shells 2>/dev/null || echo '$HOME/.nix-profile/bin/zsh' >>/etc/shells" || true
$SUDO chsh -s "$ZSH_BIN" "$(whoami)" || echo "chsh failed (non-fatal); start zsh manually if needed." >&2

echo "WELCOME TO NIXLAND"
exec zsh
