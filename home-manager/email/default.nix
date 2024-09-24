{config, ...}: {
  imports = [./neomutt];
  programs = {
    alot.enable = true;
    notmuch.enable = true;
    mbsync.enable = true;
  };

  accounts.email.accounts = {
    "bergaborgen" = {
      primary = true;
      mbsync = {
        enable = true;
        create = "maildir";
      };
      notmuch.enable = true;
      address = "ekonomigruppen@bergaborgen.se";
      userName = "ekonomigruppen@bergaborgen.se";
      realName = "Ekonomigruppen";
      passwordCommand = [
        ''cat ${config.sops.secrets."mail/ekonomigruppen".path}''
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
