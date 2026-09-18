{
  pkgs,
  config,
  inputs,
  ...
}: {
  programs.firefox = {
    configPath = ".mozilla/firefox";
    enable = true;
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
  };
}
