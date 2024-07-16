{ config, pkgs, ... }:

{
    
  console = {
    font = "lat9w-16";
    keyMap = "us";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
}