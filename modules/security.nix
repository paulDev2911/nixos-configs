{ config, pkgs, ... }:

{
  # Firewall aktiviert
  networking.firewall.enable = true;
  
  # Sudo-Rechte nur für Mitglieder der wheel-Gruppe
  security.sudo.execWheelOnly = true;
  
  # Kernel Security Hardening
  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = 1;                # SYN flood protection
    "net.ipv4.conf.all.accept_redirects" = 0;     # Ignore ICMP redirects (IPv4)
    "net.ipv6.conf.all.accept_redirects" = 0;     # Ignore ICMP redirects (IPv6)
    "kernel.dmesg_restrict" = 1;                  # Restrict dmesg access
    "kernel.kptr_restrict" = 2;                   # Hide kernel pointers
  };
  
  # Fail2ban: Automatisches Bannen nach fehlgeschlagenen Login-Versuchen
  services.fail2ban = {
    enable = true;
    maxretry = 5;      # Nach 5 Fehlversuchen
    bantime = "1h";    # 1 Stunde Ban
  };

  # System-Monitoring und Security Auditing
  environment.systemPackages = with pkgs; [
    osquery
  ];
}