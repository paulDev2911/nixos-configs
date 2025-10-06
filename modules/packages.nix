{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editor
    nano
    
    # Command-line tools
    wget
    git
    htop
    curl
    tree
    
    # VPN & Privacy
    mullvad-vpn
    mullvad-browser
    tor-browser
    
    # Development
    vscodium
    wireshark
    
    # Productivity
    onlyoffice-bin
    thunderbird
    keepassxc
    
    # Browser
    brave
  ];
}