#!/usr/bin/env bash
set -euo pipefail

# Refreshes pkgs/proton-meet.json (read by pkgs/proton-meet.nix): looks up the
# newest Stable release in Proton's version.json, downloads the .deb, checks it
# against Proton's published SHA-256, and records version + SRI hash + the
# Electron major it was built for (usr/lib/proton-meet/version in the .deb).
# The package runs on nixpkgs' `electron_<major>`; if nixpkgs doesn't have that
# one yet, the framebook build fails and update-flake.yml commits nothing.
#
#   scripts/update-proton-meet.sh
#
# Used by .github/workflows/update-flake.yml; runnable locally.

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PIN="$REPO_DIR/pkgs/proton-meet.json"
FEED="https://proton.me/download/meet/linux/version.json"

# Re-exec with the tools on PATH if any are missing (e.g. no dpkg-deb locally).
missing=false
for tool in jq curl dpkg-deb sha256sum; do command -v "$tool" >/dev/null || missing=true; done
if $missing && [[ -z "${_UPM_IN_SHELL:-}" ]]; then
  export _UPM_IN_SHELL=1
  exec nix shell --inputs-from "$REPO_DIR" nixpkgs#jq nixpkgs#curl nixpkgs#dpkg nixpkgs#coreutils \
    --command "$0" "$@"
fi

old_version="$(jq -r '.version' "$PIN")"

# Releases are listed newest first (same assumption nixpkgs' proton-pass
# updater makes for Proton's feeds).
release="$(curl -fsSL --retry 3 "$FEED" |
  jq -c '[.Releases[] | select(.CategoryName == "Stable")] | first')"
version="$(jq -r '.Version' <<<"$release")"
url="$(jq -r '.File[] | select(.Url | endswith(".deb")) | .Url' <<<"$release")"
sha256="$(jq -r '.File[] | select(.Url | endswith(".deb")) | .Sha256CheckSum' <<<"$release")"
if [[ -z "$version" || "$version" == null || -z "$url" || -z "$sha256" ]]; then
  echo "error: could not parse latest Stable .deb from $FEED" >&2
  exit 1
fi

if [[ "$version" == "$old_version" ]]; then
  echo "proton-meet $version (unchanged)"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
deb="$tmp/proton-meet.deb"
curl -fsSL --retry 3 -o "$deb" "$url"

if [[ "$(sha256sum "$deb" | cut -d' ' -f1)" != "$sha256" ]]; then
  echo "error: $url does not match the SHA-256 in $FEED" >&2
  exit 1
fi

electron_version="$(dpkg-deb --fsys-tarfile "$deb" | tar -xO ./usr/lib/proton-meet/version)"
electron="${electron_version%%.*}"
if [[ ! "$electron" =~ ^[0-9]+$ ]]; then
  echo "error: unexpected Electron version '$electron_version' in .deb" >&2
  exit 1
fi

hash="$(nix hash file --type sha256 --sri "$deb" 2>/dev/null)"
jq -n --arg v "$version" --arg h "$hash" --arg e "$electron" \
  '{version: $v, hash: $h, electron: $e}' >"$PIN"

echo "proton-meet $old_version -> $version (electron $electron_version)"
