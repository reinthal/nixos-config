{
  pkgs,
  config,
  ...
}: let
  homeDirectory = config.home.homeDirectory;
  cache-upload = pkgs.writeShellScriptBin "cache-upload" ''
    set -euo pipefail

    CACHE_URL="s3://reinthal-nix-store?endpoint=tree-ams5-0003.secure.backblaze.com&scheme=https"
    SIGNING_KEY="${homeDirectory}/.config/nix/signing-key.sec"

    if [[ "''${1:-}" == "--help" || "''${1:-}" == "-h" ]]; then
        echo "Usage: cache-upload [paths...]"
        echo ""
        echo "Sign and push Nix store paths to B2 cache."
        echo "If no paths given, uploads current system closure."
        exit 0
    fi

    if [[ ! -f "$SIGNING_KEY" ]]; then
        echo "Error: Signing key not found at $SIGNING_KEY"
        echo "Make sure SOPS secrets are deployed via home-manager"
        exit 1
    fi

    export AWS_SHARED_CREDENTIALS_FILE="${homeDirectory}/.aws/credentials"

    if [[ $# -eq 0 ]]; then
        if [[ -e /run/current-system ]]; then
            PATHS=("/run/current-system")
            echo "No paths specified, uploading current system closure..."
        else
            echo "Error: No paths specified and /run/current-system not found"
            exit 1
        fi
    else
        PATHS=()
        for path in "$@"; do
            if [[ -L "$path" ]]; then
                resolved=$(${pkgs.coreutils}/bin/readlink -f "$path")
                echo "Resolving $path -> $resolved"
                PATHS+=("$resolved")
            else
                PATHS+=("$path")
            fi
        done
    fi

    echo "Signing and uploading ''${#PATHS[@]} path(s) to $CACHE_URL"

    echo "Signing..."
    ${pkgs.nix}/bin/nix store sign --recursive --key-file "$SIGNING_KEY" "''${PATHS[@]}"

    echo "Uploading..."
    ${pkgs.nix}/bin/nix copy --to "$CACHE_URL" "''${PATHS[@]}"

    echo "Done."
  '';
in {
  home.packages = [cache-upload];
}
