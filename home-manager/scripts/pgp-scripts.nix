{pkgs, ...}: let
  secrets = pkgs.writeShellScriptBin "secret" ''
    set -e
    input_file=$1
    timestamp=$(date +%s)
    output_file=$input_file.$timestamp.enc

    '${pkgs.gnupg}/bin/gpg' --encrypt --armor --output "$output_file" -r "$KEYID" "$input_file"
    echo "$input_file -> $output_file"
  '';

  reveal = pkgs.writeShellScriptBin "reveal" ''
    set -e
    input_file=$1
    output_file=$(echo "$input_file" | rev | cut -c16- | rev)

    '${pkgs.gnupg}/bin/gpg' --decrypt --output "$output_file" "$input_file"
    echo "$input_file -> $output_file"
  '';
in {
  home.packages = [secrets reveal];
}
