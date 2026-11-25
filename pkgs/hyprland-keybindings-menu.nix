{
  writeScript,
  makeWrapper,
  symlinkJoin,
  bash,
  fuzzel,
  libnotify,
  coreutils,
}: let
  script =
    writeScript "hyprland-keybindings-menu"
    ''
      #!${bash}/bin/bash
      # Hyprland Keybindings Menu - Searchable fuzzel interface

      # Format: "Keybind | Description | Category"
      keybindings=(
          "SUPER + Return|Open terminal (ghostty)|Applications"
          "SUPER + Space|Application launcher (fuzzel)|Applications"
          "SUPER SHIFT + C|Bluetooth manager (bzmenu)|Applications"
          "SUPER SHIFT + V|Wi-Fi manager (iwmenu)|Applications"
          "SUPER SHIFT + B|Audio manager (pwmenu)|Applications"
          "SUPER + /|Keybindings menu (searchable)|Applications"
          "SUPER + W|Open Firefox|Applications"
          "SUPER + H|Tasks (linear.app)|Applications"
          "SUPER + J|LLM (claude-desktop)|Applications"
          "SUPER + M|Slack|Applications"
          "SUPER + N|Discord|Applications"
          "SUPER + V|Email (Proton)|Applications"
          "SUPER + C|Code (VSCodium)|Applications"
          "SUPER + K|Signal|Applications"
          "SUPER + O|Obsidian|Applications"
          "SUPER + P|Vault (vault.reinthal.me)|Applications"
          "SUPER + L|Toggl|Applications"
          "SUPER + E|Calendar (Proton)|Applications"

          "SUPER + Q|Kill active window|Window Management"
          "SUPER + F|Toggle floating mode|Window Management"
          "SUPER + G|Toggle fullscreen|Window Management"
          "SUPER + T|Toggle split layout|Window Management"
          "ALT + Tab|Focus current or last window|Window Management"
          "SUPER + Tab|Next window (all workspaces)|Window Management"
          "SUPER SHIFT + Tab|Previous window (all workspaces)|Window Management"

          "SUPER ALT + k|Move focus up|Focus Navigation"
          "SUPER ALT + j|Move focus down|Focus Navigation"
          "SUPER ALT + l|Move focus right|Focus Navigation"
          "SUPER ALT + h|Move focus left|Focus Navigation"

          "SUPER + 1-5|Main monitor workspace 1-5|Workspaces"
          "SUPER + Space + 1-5|Secondary monitor workspace 6-10|Workspaces"
          "SUPER + Left|Previous workspace|Workspaces"
          "SUPER + Right|Next workspace|Workspaces"
          "SUPER SHIFT + 1-5|Move window to workspace 1-5|Workspaces"
          "SUPER SHIFT + Space + 1-5|Move window to workspace 6-10|Workspaces"
          "SUPER SHIFT + Left|Move window to previous workspace|Workspaces"
          "SUPER SHIFT + Right|Move window to next workspace|Workspaces"

          "SUPER + D|Dismiss notification|Notifications"
          "SUPER SHIFT + D|Dismiss all notifications|Notifications"

          "SUPER SHIFT + S|Screenshot region to clipboard|Screenshots"

          "SUPER + B|Change wallpaper|System"
          "CTRL SUPER + Q|Lock screen (swaylock)|System"
          "CTRL SUPER + G|Toggle gamemode|System"
          "CTRL ALT + D|Exit Hyprland|System"

          "XF86AudioRaiseVolume|Increase volume 5%|Audio"
          "XF86AudioLowerVolume|Decrease volume 5%|Audio"

          "SUPER + Left Click|Move window|Mouse"
          "SUPER + Right Click|Resize window|Mouse"
      )

      # Format for display in fuzzel
      menu=""
      for binding in "''${keybindings[@]}"; do
          IFS='|' read -r key desc category <<< "$binding"
          menu+="$(printf '%-30s  %-50s  [%s]\n' "$key" "$desc" "$category")\n"
      done

      # Show in fuzzel
      selected=$(echo -e "$menu" | ${fuzzel}/bin/fuzzel --dmenu \
          --prompt "Keybindings: " \
          --width=120 \
          --lines=20)

      # If something was selected, show a notification with the keybind
      if [ -n "$selected" ]; then
          keybind=$(echo "$selected" | ${coreutils}/bin/awk '{print $1, $2, $3}' | ${coreutils}/bin/xargs)
          ${libnotify}/bin/notify-send "Keybinding" "$keybind" -t 3000
      fi
    '';
in
  symlinkJoin {
    name = "hyprland-keybindings-menu";
    paths = [bash fuzzel libnotify coreutils];
    buildInputs = [makeWrapper];
    postBuild = ''
      cp ${script} $out/bin/hyprland-keybindings-menu
      wrapProgram $out/bin/hyprland-keybindings-menu --set PATH $out/bin
    '';
  }
