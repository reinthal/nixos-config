{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        search.default = "ddg";
        search.privateDefault = "ddg";
        containersForce = true;
        # optional: without this the addons need to be enabled manually after first install
        settings = {
          "extensions.autoDisableScopes" = 0;
        };

        containers = {
          liu = {
            id = 1;
            name = "liu";
            icon = "briefcase";
            color = "blue";
          };

          umu = {
            id = 2;
            name = "umu";
            icon = "cart";
            color = "turquoise";
          };

          aisafety = {
            name = "ai-safety";
            id = 3;
            icon = "fruit";
            color = "green";
          };
          oro = {
            name = "oro";
            id = 4;
            icon = "dollar";
            color = "red";
          };
        };
      };
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
  };
}
