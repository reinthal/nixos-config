{ config, pkgs, ... }:

{

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true; 
  programs.zsh.enable = true;
  users.users.ada = {
    description = "ada";
    isNormalUser = true;
    hashedPassword = "$y$j9T$HWvOqEXKNAo71pncWn0oL.$SCSg00gwPa9UzNjfFQN2q3TTpIt.7LYj7R3li51Q8m8";
    extraGroups = [ 
		 "networkmanager" 
		 "wheel"
    ];
    shell = pkgs.zsh;
    uid = 1337;
    openssh.authorizedKeys.keyFiles = [ 
        ./keys/fireside.pub
        ./keys/asperitas.pub 
    ];
  };

  users.users.kog = {
    description = "kog";
    home = "/home/kog";
    isNormalUser = true;
    hashedPassword = "$6$WMQGBij0sndI.ZxH$eBSuf/DxQvBnPqGb0qlxXQsUPFkFWc3QKufpTSpfvKMXYcI/NkIZ51vE9vE36388Yj7QnmjACHu3Kbms6dFNm.";
    extraGroups = [ 
		 "networkmanager" 
		 "wheel"
    ];
    shell = pkgs.zsh;
    uid = 1000;
    openssh.authorizedKeys.keyFiles = [ 
        ./keys/battlestation.pub
        ./keys/mbpro.pub
        ./keys/build.pub
    ];
  };
}

