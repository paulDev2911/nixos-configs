{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ salt ];

  services.salt.master.enable = true;
  services.salt.minion.enable = true;

  networking.firewall.allowedTCPPorts = [ 4505 4506 ];

  systemd.tmpfiles.rules = [
    "d /srv/salt 0755 root root -"
    "d /srv/pillar 0700 root root -"
  ];
}