# Window switcher: hold SUPER, press Tab (SHIFT + Tab or SUPER + ` goes back)
# to move through open windows, most recently focused first, and release SUPER
# to focus the selection.
#
# hyprshell registers these binds itself through Hyprland's Lua API when it
# starts, so they are not in hyprland.nix. Only its switch mode is enabled:
# no overview, no launcher (fuzzel stays on SUPER + Space).
# Options: hyprshell's crates/config-lib/src/io/config.rs, or
# `hyprshell config edit`.
{...}: {
  services.hyprshell = {
    enable = true;
    systemd.enable = true;
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

      /* No window titles: icons only. hyprshell has no option for it and GTK
         CSS has no display: none, so collapse the card's title label. */
      .client frame > label {
        font-size: 0.01px;
        color: transparent;
        min-height: 0;
        margin: 0;
        padding: 0;
      }
    '';
  };

  # graphical-session.target is also reached by the GNOME session on hosts
  # that offer both (framebook); there is no Hyprland to bind into there.
  systemd.user.services.hyprshell.Unit.ConditionEnvironment = "!XDG_CURRENT_DESKTOP=GNOME";
}
