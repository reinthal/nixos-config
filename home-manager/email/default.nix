{
  config,
  pkgs,
  ...
}: {
  programs = {
  };
  home = {
    file.".inputrc".source = ./dotfiles/.inputrc;
    stateVersion = "24.05";
    # specify my home-manager configs
    packages = with pkgs; [
      # cli
      mailspring
    ];
  };
  accounts.email.accounts = {
    "bergaborgen" = {
      primary = true;
      address = "ekonomigruppen@bergaborgen.se";
      userName = "ekonomigruppen@bergaborgen.se";
      realName = "Ekonomigruppen";
      passwordCommand = [
        ''cat ${config.home.homeDirectory}/.shhh/mail/ekonomigruppen''
      ];

      imap = {
        host = "mailcluster.loopia.se";
        port = 993;
        tls = {
          enable = true;
        };
      };

      smtp = {
        host = "mailcluster.loopia.se";
        port = 465;
        tls = {
          enable = true;
        };
      };
    };
  };
}
