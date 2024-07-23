{
  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "se_SE.UTF-8";
    LC_IDENTIFICATION = "se_SE.UTF-8";
    LC_MEASUREMENT = "se_SE.UTF-8";
    LC_MONETARY = "se_SE.UTF-8";
    LC_NAME = "se_SE.UTF-8";
    LC_NUMERIC = "se_SE.UTF-8";
    LC_PAPER = "se_SE.UTF-8";
    LC_TELEPHONE = "se_SE.UTF-8";
    LC_TIME = "se_SE.UTF-8";
  };

  console.useXkbConfig = true;
  services.xserver.xkb.layout = "us,se";
}
