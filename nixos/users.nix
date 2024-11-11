{
  config,
  pkgs,
  ...
}: {
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;
  programs.zsh.enable = true;
  # Make sure to set the appropriate user and group
  systemd.tmpfiles.rules = [
    "d /mnt/data/kog 0775 kog users - -"
  ];
  users.users.kog = {
    description = "kog";
    home = "/home/kog";
    isNormalUser = true;
    hashedPassword = "$6$WMQGBij0sndI.ZxH$eBSuf/DxQvBnPqGb0qlxXQsUPFkFWc3QKufpTSpfvKMXYcI/NkIZ51vE9vE36388Yj7QnmjACHu3Kbms6dFNm.";
    extraGroups = [
      "networkmanager"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.zsh;
    uid = 1000;
    openssh.authorizedKeys.keyFiles = [
      ./keys/openpgp.pub
    ];
  };
}
