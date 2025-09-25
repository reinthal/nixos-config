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
        containers = {
            liu = {
              id = 1;
              name = "liu";
              icon =  "briefcase";  
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
          };
        };
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
  };
}
