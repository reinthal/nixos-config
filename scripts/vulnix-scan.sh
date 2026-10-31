#!/usr/bin/env bash
set -uo pipefail

# Scans a NixOS system's runtime closure for known CVEs with vulnix and prints a
# markdown table sorted by CVSS score. Used by .github/workflows/vulnix.yml and
# runnable locally.
#
#   scripts/vulnix-scan.sh                 # build + scan this host's flake config
#   scripts/vulnix-scan.sh framebook       # build + scan another host
#   scripts/vulnix-scan.sh --system        # scan the running /run/current-system
#   scripts/vulnix-scan.sh -o out.json relay   # also keep the raw vulnix JSON
#
# Applies vulnix-whitelist.toml from the repo root if it exists.
# Exit code follows vulnix: 0 nothing found, 2 vulnerabilities found, else error.

usage() {
  sed -n '4,14p' "$0" | sed 's/^# \{0,1\}//'
}

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
host="$(hostname)"
json_out=""
system=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    -s | --system) system=true ;;
    -o | --output) json_out="$2"; shift ;;
    -*) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    *) host="$1" ;;
  esac
  shift
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if $system; then
  target=/run/current-system
  label="$(hostname) (current system)"
else
  # The out-link is a GC root, so the closure stays valid while vulnix reads it.
  nix build -L --out-link "$tmp/result" \
    "$REPO_DIR#nixosConfigurations.$host.config.system.build.toplevel" || exit 1
  target="$tmp/result"
  label="$host"
fi

wl=()
[[ -f "$REPO_DIR/vulnix-whitelist.toml" ]] && wl=(--whitelist "$REPO_DIR/vulnix-whitelist.toml")

nix run nixpkgs#vulnix -- --closure --json "${wl[@]}" "$target" > "$tmp/vulnix.json"
rc=$?
if [[ $rc -ne 0 && $rc -ne 2 ]]; then
  echo "vulnix exited with $rc" >&2
  exit "$rc"
fi

[[ -n "$json_out" ]] && cp "$tmp/vulnix.json" "$json_out"

echo "### vulnix: $label ($(jq length "$tmp/vulnix.json") affected packages)"
echo
echo "| Max CVSS | Package | CVEs |"
echo "|---:|---|---|"
jq -r '
  map(. + {max: ([.cvssv3_basescore[]?] | max // 0)})
  | sort_by(-.max)[]
  | "| \(.max) | \(.name) | \(.affected_by | join(", ")) |"
' "$tmp/vulnix.json"

exit "$rc"
