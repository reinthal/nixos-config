{pkgs, ...}: let
  swww-wallpaper = pkgs.writeShellScriptBin "swww-wallpaper" ''
    # Default wallpaper directory
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

    # Create directory if it doesn't exist
    mkdir -p "$WALLPAPER_DIR"

    # Check if directory has wallpapers
    if [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
        ${pkgs.libnotify}/bin/notify-send "No wallpapers found" "Add images to $WALLPAPER_DIR"
        exit 1
    fi

    # Pick a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)

    if [ -z "$WALLPAPER" ]; then
        ${pkgs.libnotify}/bin/notify-send "No wallpapers found" "Add .jpg, .png, or .gif files to $WALLPAPER_DIR"
        exit 1
    fi

    # Set the wallpaper
    ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type fade --transition-fps 60

    ${pkgs.libnotify}/bin/notify-send "Wallpaper changed" "$(basename "$WALLPAPER")"
  '';
in {
  home.packages = [swww-wallpaper];
}
