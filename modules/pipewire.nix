{ config, ... }:
{
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32bit = true;
    pulse.enable = true;
    # if you want to use jack applications, uncomment this
    #jack.enable = true;
  };  
}
