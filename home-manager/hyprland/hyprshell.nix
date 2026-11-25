# Window switcher: hold SUPER, press Tab (SHIFT + Tab or SUPER + ` goes back)
# to move through open windows, most recently focused first, and release SUPER
# to focus the selection.
#
# hyprshell registers these binds itself through Hyprland's Lua API when it
# starts, so they are not in hyprland.nix. Only its switch mode is enabled:
# no overview, no launcher (fuzzel stays on SUPER + Space).
# Options: hyprshell's crates/config-lib/src/io/config.rs, or
# `hyprshell config edit`.
{pkgs, ...}: {
  services.hyprshell = {
    enable = true;
    systemd.enable = true;
    # Local patch: a switcher card whose icon cannot be resolved (generic
    # fallback, or a name the icon theme lacks) gets the `no-icon` CSS class,
    # so the style below can show the title there instead.
    package = pkgs.hyprshell.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./hyprshell-no-icon-class.patch];
    });
    settings = {
      version = 4;
      windows.switch = {
        modifier = "super";
        key = "Tab";
        # All windows, not just the ones on the focused monitor (the default).
        filter_by = [];
        exclude_workspaces = "special:.*";
      };
    };

    # Matches wayle's Everforest palette and font (gui/wayle.nix): panel in
    # `bg`, cards in `surface`, selection outlined in `primary`.
    style = ''
      :root {
        --bg-window-color: rgba(51, 60, 67, 0.94); /* bg       #333c43 */
        --bg-color: #3a464c;                       /* surface  */
        --bg-color-hover: #4d5960;                 /* elevated */
        --border-color: #4d5960;                   /* elevated */
        --border-color-active: #7fbbb3;            /* primary  */
        --text-color: #d3c6aa;                     /* fg       */
        --border-radius: 12px;
        --border-size: 2px;
        --border-style: solid;
        --window-padding: 10px;
      }

      * {
        font-family: "UbuntuSans Nerd Font", sans-serif;
      }

      .monitor {
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.45);
      }

      .client {
        font-size: 1rem;
        margin: 4px;
      }

      .client.active {
        background: #4d5960;
        box-shadow: 0 0 0 1px #7fbbb3;
      }

      /* Icons only, no window titles. hyprshell has no option for it and GTK
         CSS has no display: none, so collapse the card's title label. */
      .client:not(.no-icon) frame > label {
        font-size: 0.01px;
        color: transparent;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      /* No icon found (patched hyprshell sets .no-icon): show the title
         instead of a broken image. */
      .client.no-icon frame > label {
        font-size: 1.1rem;
        padding: 6px 8px 0 8px;
      }

      .client.no-icon image {
        opacity: 0;
      }
    '';
  };

  # graphical-session.target is also reached by the GNOME session on hosts
  # that offer both (framebook); there is no Hyprland to bind into there.
  systemd.user.services.hyprshell.Unit.ConditionEnvironment = "!XDG_CURRENT_DESKTOP=GNOME";

  # By default hyprshell treats an icon name as available if any installed
  # theme has it (Papirus, MoreWaita, Qogir...), not just the active one. So
  # classes like chromium-browser and md.obsidian.Obsidian were asked of GTK,
  # which (Adwaita + hicolor) has no such icon. With this, only the active
  # theme counts and those windows fall through to their .desktop file's Icon=
  # (chromium, obsidian), which hicolor has.
  systemd.user.services.hyprshell.Service.Environment = ["HYPRSHELL_NO_ALL_ICONS=1"];
}
