{
  pkgs,
  inputs,
  ...
}: {
  # Module installing brave as default browser
  home.packages = [inputs.zen-browser.packages."${pkgs.system}".specific];

  home.sessionVariables = {
    DEFAULT_BROWSER = "zen";
  };
}
