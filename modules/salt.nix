{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ salt ];

  # Temporär deaktiviert wegen Crypto-Bug
  services.salt.master.enable = false;
  services.salt.minion.enable = false;

  networking.firewall.allowedTCPPorts = [ 4505 4506 ];

  systemd.tmpfiles.rules = [
    "d /srv/salt 0755 root root -"
    "d /srv/pillar 0700 root root -"
    "d /etc/salt/pki/master 0755 root root -"
    "d /etc/salt/pki/minion 0755 root root -"
  ];
}