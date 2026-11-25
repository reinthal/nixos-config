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
  };

  # graphical-session.target is also reached by the GNOME session on hosts
  # that offer both (framebook); there is no Hyprland to bind into there.
  systemd.user.services.hyprshell.Unit.ConditionEnvironment = "!XDG_CURRENT_DESKTOP=GNOME";
}
