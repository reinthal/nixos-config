{pkgs, ...}: 
{
    environment.systemPackages = with pkgs; [ 
        teams-for-linux
        slack-term
    ];
}