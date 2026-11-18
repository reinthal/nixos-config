# Linux-consistent keybindings on macOS, mirroring home-manager/hyprland.
#
# Linux is the source of truth: SUPER drives the window manager and CTRL
# drives applications. On the Mac that means:
#   - CMD is SUPER. Karabiner rewrites physical cmd+<wm key> to
#     cmd+ctrl+alt+<key> ("hyper"), which AeroSpace binds. The indirection
#     keeps AeroSpace from swallowing the cmd+<key> that Karabiner
#     synthesizes for apps below.
#   - CTRL is the app modifier. Outside terminals, Karabiner rewrites
#     ctrl+c/v/t/w/... to cmd+c/v/t/w/... Terminals keep ctrl (SIGINT etc.)
#     and copy/paste on ctrl+shift+c/v, as kitty/ghostty do on Linux.
#   - Caps lock: escape when tapped, control when held (caps-to-ctrl-esc.nix).
{
  pkgs,
  lib,
  ...
}: let
  hyper = ["left_command" "left_control" "left_option"];
  hyperPrefix = "cmd-ctrl-alt";

  # Single source for both sides: Karabiner key_code -> AeroSpace key name.
  # Every key here is routed cmd -> hyper; its action lives in wmBinds.
  wmKeys = {
    "return_or_enter" = "enter";
    "spacebar" = "space";
    "left_arrow" = "left";
    "right_arrow" = "right";
    "q" = "q";
    "f" = "f";
    "a" = "a";
    "g" = "g";
    "w" = "w";
    "e" = "e";
    "p" = "p";
    "o" = "o";
    "m" = "m";
    "n" = "n";
    "v" = "v";
    "c" = "c";
    "h" = "h";
    "j" = "j";
    "k" = "k";
    "l" = "l";
  };
  workspaces = map toString [1 2 3 4 5 6 7];

  # Hyprland special-workspace scratchpads -> show/hide a native app.
  toggleApp = pkgs.writeShellScript "toggle-app" ''
    # usage: toggle-app <bundle id>
    # Hide the app when it is frontmost, otherwise launch/focus it.
    front=$(/usr/bin/osascript -e 'tell application "System Events" to get bundle identifier of first application process whose frontmost is true')
    if [ "$front" = "$1" ]; then
      /usr/bin/osascript -e "tell application \"System Events\" to set visible of (first application process whose bundle identifier is \"$1\") to false"
    else
      /usr/bin/open -b "$1"
    fi
  '';
  toggle = bundleId: "exec-and-forget ${toggleApp} ${bundleId}";
  webApp = url: "exec-and-forget /usr/bin/open -na \"Google Chrome\" --args --app=${url}";

  # Same letters as hyprland.nix; actions as close as AeroSpace allows.
  wmBinds = {
    "enter" = "exec-and-forget /usr/bin/open -na kitty";
    # Re-opening Raycast pops its launcher (fuzzel on Linux).
    "space" = "exec-and-forget /usr/bin/open -a Raycast";
    "left" = "workspace prev";
    "right" = "workspace next";
    "q" = "close --quit-if-last-window";
    "f" = "layout floating tiling";
    "a" = "layout tiles horizontal vertical";
    "g" = "fullscreen";
    "w" = "exec-and-forget /usr/bin/open -a \"Google Chrome\"";
    "e" = webApp "https://calendar.proton.me/u/0/";
    "p" = webApp "https://vault.reinthal.me";
    "o" = toggle "md.obsidian";
    "m" = toggle "com.tinyspeck.slackmacgap";
    "n" = toggle "com.hnc.Discord";
    "v" = webApp "https://mail.proton.me/";
    "c" = toggle "com.microsoft.VSCode";
    "h" = webApp "https://linear.app/reinthal/team/REI/active";
    "j" = toggle "com.anthropic.claudefordesktop";
    "k" = toggle "org.whispersystems.signal-desktop";
    "l" = webApp "https://track.toggl.com/timer";
  };

  terminals = [
    "^net\\.kovidgoyal\\.kitty$"
    "^com\\.mitchellh\\.ghostty$"
    "^com\\.apple\\.Terminal$"
    "^com\\.googlecode\\.iterm2$"
  ];
  browsers = [
    "^org\\.chromium\\.Chromium$"
    "^com\\.google\\.Chrome$"
    "^org\\.mozilla\\.firefox$"
    "^com\\.apple\\.Safari$"
  ];
  notIn = ids: [
    {
      type = "frontmost_application_unless";
      bundle_identifiers = ids;
    }
  ];
  onlyIn = ids: [
    {
      type = "frontmost_application_if";
      bundle_identifiers = ids;
    }
  ];

  # from <mods>+<key> (exact match) -> to <toMods>+<toKey>
  remap = {
    key,
    mods ? [],
    optional ? [],
    toKey ? key,
    toMods,
    conditions ? [],
  }:
    {
      type = "basic";
      from = {
        key_code = key;
        modifiers =
          {mandatory = mods;}
          // lib.optionalAttrs (optional != []) {inherit optional;};
      };
      to = [
        {
          key_code = toKey;
          modifiers = toMods;
        }
      ];
    }
    // lib.optionalAttrs (conditions != []) {inherit conditions;};

  rules = [
    {
      description = "Caps lock: escape on tap, control on hold";
      manipulators = [
        {
          type = "basic";
          from = {
            key_code = "caps_lock";
            modifiers.optional = ["any"];
          };
          to = [{key_code = "left_control";}];
          to_if_alone = [{key_code = "escape";}];
        }
      ];
    }
    {
      description = "Window manager: cmd -> hyper for AeroSpace";
      manipulators =
        lib.mapAttrsToList (key: _:
          remap {
            inherit key;
            mods = ["command"];
            toMods = hyper;
          })
        wmKeys
        ++ map (key:
          remap {
            inherit key;
            mods = ["command"];
            toMods = hyper;
          })
        workspaces
        ++ map (key:
          remap {
            inherit key;
            mods = ["command" "shift"];
            toMods = hyper ++ ["left_shift"];
          }) (workspaces ++ ["left_arrow" "right_arrow"]);
    }
    {
      description = "Screenshot: cmd+shift+s -> region to clipboard";
      manipulators = [
        (remap {
          key = "s";
          mods = ["command" "shift"];
          toKey = "4";
          toMods = ["left_command" "left_control" "left_shift"];
        })
      ];
    }
    {
      description = "Layout switch: alt+space -> previous input source";
      manipulators = [
        (remap {
          key = "spacebar";
          mods = ["option"];
          toMods = ["left_control"];
        })
      ];
    }
    {
      description = "App shortcuts: ctrl -> cmd (not in terminals)";
      manipulators =
        map (key:
          remap {
            inherit key;
            mods = ["control"];
            toMods = ["left_command"];
            conditions = notIn terminals;
          })
        ["a" "c" "v" "x" "z" "f" "t" "w" "r" "l" "n" "s" "o" "p" "equal_sign" "hyphen" "0"]
        ++ map (key:
          remap {
            inherit key;
            mods = ["control" "shift"];
            toMods = ["left_command" "left_shift"];
            conditions = notIn terminals;
          }) ["z" "t" "n" "p"];
    }
    {
      description = "Text navigation: Linux word/line movement (not in terminals)";
      manipulators = let
        nav = key: mods: toKey: toMods:
          remap {
            inherit key mods toKey toMods;
            optional = ["shift"];
            conditions = notIn terminals;
          };
      in [
        (nav "left_arrow" ["control"] "left_arrow" ["left_option"])
        (nav "right_arrow" ["control"] "right_arrow" ["left_option"])
        (nav "delete_or_backspace" ["control"] "delete_or_backspace" ["left_option"])
        (nav "delete_forward" ["control"] "delete_forward" ["left_option"])
        (nav "home" [] "left_arrow" ["left_command"])
        (nav "end" [] "right_arrow" ["left_command"])
        (nav "home" ["control"] "up_arrow" ["left_command"])
        (nav "end" ["control"] "down_arrow" ["left_command"])
      ];
    }
    {
      description = "Browser tabs: alt/ctrl+N -> cmd+N";
      manipulators = lib.concatMap (key:
        map (mod:
          remap {
            inherit key;
            mods = [mod];
            toMods = ["left_command"];
            conditions = onlyIn browsers;
          }) ["option" "control"]) (map toString [1 2 3 4 5 6 7 8 9]);
    }
  ];
in {
  homebrew.casks = ["karabiner-elements" "google-chrome"];

  # Karabiner reads only this file; edits made in its GUI won't persist.
  home-manager.users.kog.xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
    profiles = [
      {
        name = "Default";
        selected = true;
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        complex_modifications.rules = rules;
      }
    ];
  };

  services.aerospace = {
    enable = true;
    settings = {
      mode.main.binding =
        lib.mapAttrs' (_: k: lib.nameValuePair "${hyperPrefix}-${k}" wmBinds.${k}) wmKeys
        // lib.listToAttrs (lib.concatMap (i: [
            (lib.nameValuePair "${hyperPrefix}-${i}" "workspace ${i}")
            (lib.nameValuePair "${hyperPrefix}-shift-${i}" "move-node-to-workspace ${i}")
          ])
          workspaces)
        // {
          "${hyperPrefix}-shift-left" = "move-node-to-workspace prev";
          "${hyperPrefix}-shift-right" = "move-node-to-workspace next";
          # Not routed through Karabiner: no app uses these.
          "alt-tab" = "focus-back-and-forth";
          "cmd-alt-h" = "focus left";
          "cmd-alt-j" = "focus down";
          "cmd-alt-k" = "focus up";
          "cmd-alt-l" = "focus right";
        };
    };
  };
}
