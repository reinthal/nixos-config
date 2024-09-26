{config, ...}: let
  homeDirectory = config.home.homeDirectory;
in {
  imports = [./neomutt];
  programs = {
    alot.enable = true;
    notmuch.enable = true;
    astroid = {
      enable = true;
      extraConfig = {
        
      };
    };
    msmtp.enable = true;
    mbsync.enable = true;
  };

  accounts.email.accounts = {
    "bergaborgen" = {
      primary = true;
      address = "ekonomigruppen@bergaborgen.se";
      userName = "ekonomigruppen@bergaborgen.se";
      realName = "Ekonomigruppen";
      passwordCommand = [
        ''cat ${homeDirectory}/.shhh/mail/ekonomigruppen''
      ];

      astroid = {
        enable = true;
        sendMailCommand = "msmtp --read-envelope-from --read-recipients --account";
      };

      neomutt = {
        enable = true;
        mailboxName = "Ekonomigruppen";
        mailboxType = "imap";
      };

      mbsync = {
        enable = true;
        create = "maildir";
      };

      notmuch.enable = true;
      offlineimap.enable = true;
      msmtp.enable = true;

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
