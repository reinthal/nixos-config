{
  pkgs,
  config,
  inputs,
  ...
}: {
  programs.firefox = {
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    enable = true;
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
  };
}
