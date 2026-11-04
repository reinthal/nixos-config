#!/usr/bin/env bash
set -euo pipefail

# Refreshes home-manager/gui/chromium-extensions.json: for every extension id in
# it, downloads the current CRX from the Chrome Web Store, reads its version
# from manifest.json and records version + SRI hash. home-manager/gui/base.nix
# turns each entry into a pinned fetchurl + programs.chromium.extensions
# `crxPath` (ungoogled-chromium can't install from the Web Store itself).
#
#   scripts/update-chromium-extensions.sh
#
# To add an extension: add `"<id>": {"name": "<label>"}` to the JSON, run this.
# Used by .github/workflows/update-flake.yml; runnable locally.

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PINS="$REPO_DIR/home-manager/gui/chromium-extensions.json"

# Re-exec with the tools on PATH if any are missing (e.g. no unzip locally).
missing=false
for tool in unzip jq curl; do command -v "$tool" >/dev/null || missing=true; done
if $missing && [[ -z "${_UCE_IN_SHELL:-}" ]]; then
  export _UCE_IN_SHELL=1
  exec nix shell --inputs-from "$REPO_DIR" nixpkgs#unzip nixpkgs#jq nixpkgs#curl \
    --command "$0" "$@"
fi

# The Web Store serves the newest CRX compatible with this Chromium version.
prodversion="$(nix eval --raw --inputs-from "$REPO_DIR" nixpkgs#ungoogled-chromium.version)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

new="$(jq '.' "$PINS")"
changed=()
for id in $(jq -r 'keys[]' "$PINS"); do
  name="$(jq -r --arg id "$id" '.[$id].name' "$PINS")"
  old_version="$(jq -r --arg id "$id" '.[$id].version // ""' "$PINS")"
  crx="$tmp/$id.crx"
  url="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=${prodversion}&acceptformat=crx3&x=id%3D${id}%26uc"
  curl -fsSL --retry 3 -o "$crx" "$url"
  if [[ ! -s "$crx" || "$(head -c4 "$crx")" != "Cr24" ]]; then
    echo "error: $name ($id): Web Store returned no CRX (delisted or incompatible?)" >&2
    exit 1
  fi
  # CRX3 = header + zip; unzip skips the header but warns (exit 1), so ignore rc.
  version="$( (unzip -p "$crx" manifest.json 2>/dev/null || true) | jq -r '.version')"
  if [[ -z "$version" || "$version" == null ]]; then
    echo "error: $name ($id): could not read version from manifest.json" >&2
    exit 1
  fi
  hash="$(nix hash file --type sha256 --sri "$crx" 2>/dev/null)"
  new="$(jq --arg id "$id" --arg v "$version" --arg h "$hash" \
    '.[$id].version = $v | .[$id].hash = $h' <<<"$new")"
  if [[ "$version" != "$old_version" ]]; then
    changed+=("$name ${old_version:-new} -> $version")
  fi
  printf '%-28s %s\n' "$name" "$version"
done

printf '%s\n' "$new" >"$PINS"

if ((${#changed[@]})); then
  echo
  echo "updated:"
  printf '  %s\n' "${changed[@]}"
fi
