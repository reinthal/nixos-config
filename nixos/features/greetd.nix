{
  pkgs,
  lib,
  config,
  ...
}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --greeting 'Welcome' \
          --theme 'border=darkgray;text=cyan;prompt=green;time=gray;action=cyan;button=green;container=darkgray;input=gray' \
          --asterisks \
          --user-menu \
          --cmd ${lib.getExe config.programs.hyprland.package}
      '';
    };
  };

  environment.etc."greetd/environments".text = ''
    hyprland
  '';
}
