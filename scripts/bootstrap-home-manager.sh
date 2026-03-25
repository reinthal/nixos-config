#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a Linux (Ubuntu/Debian) host with Nix + Home Manager and this repo's CLI config.

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Do not run this script as root." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required." >&2
  exit 1
fi

REPO_DIR_DEFAULT="$HOME/nixos-config"
REPO_DIR="${REPO_DIR:-$REPO_DIR_DEFAULT}"
REPO_URL="${REPO_URL:-https://github.com/reinthal/nixos-config}"

ensure_line() {
  local line="$1" file="$2"
  if ! sudo sh -c "grep -qxF '$line' '$file'"; then
    printf '%s\n' "$line" | sudo tee -a "$file" >/dev/null
  fi
}

# Base packages
sudo apt update
sudo apt install -y curl git gh vim zsh

# Install Nix (daemon mode)
if ! command -v nix >/dev/null 2>&1; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # Ensure Nix is available in this shell without requiring a new login.
  if [[ -r /etc/profile.d/nix.sh ]]; then
    # shellcheck disable=SC1091
    . /etc/profile.d/nix.sh
  fi
fi

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

# Allow flakes and add trusted users/substituters
ensure_line "experimental-features = nix-command flakes" /etc/nix/nix.conf
ensure_line "trusted-users = root $(whoami)" /etc/nix/nix.conf
ensure_line "extra-substituters = https://devenv.cachix.org" /etc/nix/nix.conf
ensure_line "extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= reinthal-cache.cachix.org-1:wFPDVH/makS72ZY3Y8jA0BehXDBhQ3syqo0UJu7oah8=" /etc/nix/nix.conf

# Ensure zsh shells are allowed
ensure_line "$(command -v zsh)" /etc/shells
ensure_line "/home/$(whoami)/.nix-profile/bin/zsh" /etc/shells

# Restart Nix daemon to pick up nix.conf changes
sudo systemctl restart nix-daemon

# Detect system architecture and choose appropriate flake config
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    FLAKE_CONFIG="kog@cli"
    ;;
  aarch64|arm64)
    FLAKE_CONFIG="kog@cli-aarch64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

echo "Detected architecture: $ARCH, using flake config: $FLAKE_CONFIG"

# Install the CLI home-manager config and switch shell
home-manager switch --flake ".#$FLAKE_CONFIG" --impure -b bkp
sudo chsh -s "$(command -v zsh)" "$(whoami)"

echo "WELCOME TO NIXLAND"
exec zsh
