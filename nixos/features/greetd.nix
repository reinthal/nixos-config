{pkgs, lib, config, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
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
