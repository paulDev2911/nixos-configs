{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ 
    salt_3006  # Verwende stabile Version statt neueste
  ];

  services.salt.master = {
    enable = true;
    package = pkgs.salt_3006;
  };
  
  services.salt.minion = {
    enable = true;
    package = pkgs.salt_3006;
  };

  networking.firewall.allowedTCPPorts = [ 4505 4506 ];

  systemd.tmpfiles.rules = [
    "d /srv/salt 0755 root root -"
    "d /srv/pillar 0700 root root -"
  ];
}