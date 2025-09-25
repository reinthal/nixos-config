{
  pkgs,
  inputs,
  ...
}: {
  # Module installing brave as default browser
  home.packages = [
    firefox
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
  };
}
