{ config, pkgs, ... }:
{
  # Firewall aktiviert
  networking.firewall.enable = true;
  
  # Sudo-Rechte nur für Mitglieder der wheel-Gruppe
  security.sudo.execWheelOnly = true;
  
  # Hardened Kernel - Kernel mit zusätzlichen Security-Patches
  boot.kernelPackages = pkgs.linuxPackages;
  
  # Kernel Security Hardening
  boot.kernel.sysctl = {
    # Netzwerk-Schutz
    "net.ipv4.tcp_syncookies" = 1;                # SYN flood protection
    "net.ipv4.conf.all.accept_redirects" = 0;     # Ignore ICMP redirects (IPv4)
    "net.ipv6.conf.all.accept_redirects" = 0;     # Ignore ICMP redirects (IPv6)
    
    # Kernel-Härtung
    "kernel.dmesg_restrict" = 1;                  # Restrict dmesg access
    "kernel.kptr_restrict" = 2;                   # Hide kernel pointers
    "kernel.yama.ptrace_scope" = 2;               # Disable ptrace (debugging) für alle Prozesse
    "kernel.unprivileged_bpf_disabled" = 1;       # Verhindert unprivilegierte BPF-Nutzung
    
    # JIT-Compiler Härtung
    "net.core.bpf_jit_harden" = 2;                # Härtung des BPF JIT-Compilers
  };
  
  # Fail2ban: Automatisches Bannen nach fehlgeschlagenen Login-Versuchen
  services.fail2ban = {
    enable = true;
    maxretry = 5;      # Nach 5 Fehlversuchen
    bantime = "1h";    # 1 Stunde Ban
  };
  
  # AppArmor Mandatory Access Control
  security.apparmor = {
    enable = true;
    packages = [ pkgs.apparmor-profiles ];
  };
  
  # USB Guard - Alle USB-Geräte blocken
  services.usbguard = {
    enable = true;
    
    # Alle USB-Geräte blocken, außer die beim Boot schon da sind
    rules = ''
      allow with-interface equals { 09:00:00 }  # USB Hubs erlauben
    '';
    
    # Interaktiver Modus: Bei jedem neuen USB-Gerät nachfragen
    implicitPolicyTarget = "block";
    
    # GUI Notifications
    dbus.enable = true;
  };

  # Audit Logging - System-Überwachung
  security.auditd.enable = true;
  
  security.audit = {
    enable = true;
    rules = [
      "-w /etc/shadow -p wa -k shadow_access"      # Überwache Zugriffe auf Passwort-Datei
      "-w /etc/passwd -p wa -k passwd_access"      # Überwache Zugriffe auf User-Datei
      "-w /etc/sudoers -p wa -k sudoers_access"    # Überwache Sudo-Konfiguration
      "-a exit,always -F arch=b64 -S execve -k exec"  # Logge alle ausgeführten Programme
    ];
  };
  
  # System-Monitoring und Security Auditing
  environment.systemPackages = with pkgs; [
    osquery            # System-Monitoring Framework
    apparmor-utils     # AppArmor CLI-Tools
    usbguard           # USB-Device Management
    usbguard-notifier  # Desktop Benachrichtigungen für USB
  ];
}