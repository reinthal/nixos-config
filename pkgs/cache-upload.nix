{ writeScript
, makeWrapper
, symlinkJoin
, nix
, bash
, coreutils
}:
let
  script = writeScript "cache-upload"
    ''
    #!${bash}/bin/bash
    #
    # Upload Nix store paths to the private Minio cache
    # Usage: cache-upload [paths...]
    #
    # If no paths are provided, uploads the current system's closure.
    # Examples:
    #   cache-upload                           # Upload current system
    #   cache-upload /nix/store/...            # Upload specific path
    #   cache-upload result                    # Upload build result

    set -euo pipefail

    # Show help
    if [[ "$#" -eq 1 ]] && [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: cache-upload [paths...]"
        echo ""
        echo "Upload Nix store paths to the private Minio cache"
        echo ""
        echo "If no paths are provided, uploads the current system's closure."
        echo ""
        echo "Examples:"
        echo "  cache-upload                           # Upload current system"
        echo "  cache-upload /nix/store/...            # Upload specific path"
        echo "  cache-upload result                    # Upload build result"
        exit 0
    fi

    CACHE_URL="s3://reinthal-nix-store?endpoint=tree-ams5-0003.secure.backblaze.com&scheme=https"

    # Signing key must be system-level only (security: no user-writable fallback)
    SIGNING_KEY="/etc/nix/signing-key.sec"
    if [[ ! -f "$SIGNING_KEY" ]]; then
        echo "Error: Signing key not found at $SIGNING_KEY"
        echo "This script requires system-level secrets from nixos/features/sops.nix"
        echo "Make sure SOPS secrets are deployed: sudo nixos-rebuild switch"
        exit 1
    fi

    echo "Using signing key: $SIGNING_KEY"

    # Determine what to upload
    if [[ $# -eq 0 ]]; then
        # Upload current system closure
        if [[ -e /run/current-system ]]; then
            PATHS="/run/current-system"
            echo "No paths specified, uploading current system closure..."
        else
            echo "Error: No paths specified and /run/current-system not found"
            echo "Usage: cache-upload [paths...]"
            exit 1
        fi
    else
        PATHS="$@"
    fi

    # Resolve symlinks (like 'result') to actual store paths
    RESOLVED_PATHS=()
    for path in $PATHS; do
        if [[ -L "$path" ]]; then
            resolved=$(${coreutils}/bin/readlink -f "$path")
            echo "Resolving $path -> $resolved"
            RESOLVED_PATHS+=("$resolved")
        else
            RESOLVED_PATHS+=("$path")
        fi
    done

    echo "Signing and uploading paths to $CACHE_URL"
    echo "Paths: ''${RESOLVED_PATHS[@]}"

    # Sign the paths
    echo "Signing paths..."
    ${nix}/bin/nix store sign --recursive --key-file "$SIGNING_KEY" "''${RESOLVED_PATHS[@]}"

    # Upload to cache
    echo "Uploading to cache..."
    ${nix}/bin/nix copy --to "$CACHE_URL" "''${RESOLVED_PATHS[@]}"

    echo "✓ Successfully uploaded to cache"
    '';
in
symlinkJoin {
  name = "cache-upload";
  paths = [ bash nix coreutils ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
  cp ${script} $out/bin/cache-upload
  wrapProgram $out/bin/cache-upload --set PATH $out/bin
  '';
}
