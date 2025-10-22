{ config, pkgs, ... }:
{
  # ===== Firewall =====
  networking.firewall = {
    enable = true;
    # Deny ping requests (optional - comment out if you need ping)
    allowPing = false;
    # Log refused connections
    logRefusedConnections = true;
    logRefusedPackets = false;  # Don't log packets to reduce noise
  };

  # ===== Automatic Security Updates =====
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;  # Set to true if you want automatic reboots
    dates = "weekly";
    randomizedDelaySec = "45min";
  };

  # ===== Sudo Security =====
  # Sudo-Rechte nur für Mitglieder der wheel-Gruppe
  security.sudo = {
    execWheelOnly = true;
    # Require password every time (no timeout)
    extraConfig = ''
      Defaults timestamp_timeout=0
      Defaults lecture=always
      Defaults logfile=/var/log/sudo.log
    '';
  };

  # ===== Hardened Kernel =====
  # Use hardened kernel with additional security patches
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  
  # ===== Kernel Security Hardening =====
  boot.kernel.sysctl = {
    # ===== Network Protection =====
    "net.ipv4.tcp_syncookies" = 1;                      # SYN flood protection
    "net.ipv4.conf.all.accept_redirects" = 0;           # Ignore ICMP redirects (IPv4)
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;           # Ignore ICMP redirects (IPv6)
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;             # Don't send ICMP redirects
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;        # Don't accept source routed packets
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.log_martians" = 1;               # Log martian packets
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;         # Ignore ICMP broadcast
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;   # Ignore bogus ICMP errors
    "net.ipv4.conf.all.rp_filter" = 1;                  # Reverse path filtering
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_rfc1337" = 1;                         # Protect against time-wait assassination

    # ===== Kernel Hardening =====
    "kernel.dmesg_restrict" = 1;                        # Restrict dmesg access
    "kernel.kptr_restrict" = 2;                         # Hide kernel pointers
    "kernel.yama.ptrace_scope" = 2;                     # Disable ptrace (debugging) for all processes
    "kernel.unprivileged_bpf_disabled" = 1;             # Prevent unprivileged BPF usage
    "kernel.kexec_load_disabled" = 1;                   # Disable kexec
    "kernel.sysrq" = 0;                                 # Disable sysrq key (except for reboot)
    "kernel.unprivileged_userns_clone" = 1;             # Allow unprivileged user namespaces (needed for containers)
    "kernel.core_uses_pid" = 1;                         # Append PID to core filename

    # ===== JIT-Compiler Hardening =====
    "net.core.bpf_jit_harden" = 2;                      # Harden BPF JIT compiler

    # ===== Memory Protection =====
    "vm.mmap_rnd_bits" = 32;                            # Increase ASLR entropy
    "vm.mmap_rnd_compat_bits" = 16;                     # Increase ASLR entropy for 32-bit

    # ===== Filesystem Hardening =====
    "fs.protected_hardlinks" = 1;                       # Prevent hardlink attacks
    "fs.protected_symlinks" = 1;                        # Prevent symlink attacks
    "fs.protected_fifos" = 2;                           # Prevent FIFO attacks
    "fs.protected_regular" = 2;                         # Prevent regular file attacks
    "fs.suid_dumpable" = 0;                             # Disable core dumps for setuid programs
  };

  # ===== Additional Boot Security =====
  boot.kernelParams = [
    "slab_nomerge"              # Disable slab merging
    "slub_debug=FZ"             # Enable SLUB debugging
    "init_on_alloc=1"           # Zero memory on allocation
    "init_on_free=1"            # Zero memory on free
    "page_alloc.shuffle=1"      # Enable page allocator randomization
    "pti=on"                    # Enable Page Table Isolation
    "vsyscall=none"             # Disable vsyscalls
    "debugfs=off"               # Disable debugfs
    "oops=panic"                # Panic on oops
    "module.sig_enforce=1"      # Enforce module signatures
  ];

  # Disable kernel modules loading after boot
  security.lockKernelModules = true;
  
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
  
  # ===== Privacy & Networking =====
  # MAC Address Randomization for privacy
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";

  # Use privacy-respecting DNS
  networking.nameservers = [ "9.9.9.9" "149.112.112.112" ];  # Quad9 DNS
  networking.networkmanager.dns = "none";  # Don't let NetworkManager override DNS

  # ===== SSH Hardening =====
  services.openssh = {
    settings = {
      PermitRootLogin = "no";                    # Disable root login
      PasswordAuthentication = false;             # Only key-based auth
      KbdInteractiveAuthentication = false;       # Disable challenge-response
      X11Forwarding = false;                      # Disable X11 forwarding
      MaxAuthTries = 3;                           # Limit auth attempts
    };
    # Strong cryptography only
    extraConfig = ''
      AllowUsers *@192.168.* *@10.* *@172.16.* *@172.17.* *@172.18.* *@172.19.* *@172.20.* *@172.21.* *@172.22.* *@172.23.* *@172.24.* *@172.25.* *@172.26.* *@172.27.* *@172.28.* *@172.29.* *@172.30.* *@172.31.*
      KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
    '';
  };

  # ===== PAM Security =====
  security.pam = {
    loginLimits = [
      # Limit number of processes per user
      { domain = "*"; type = "soft"; item = "nproc"; value = "4096"; }
      { domain = "*"; type = "hard"; item = "nproc"; value = "8192"; }
      # Limit number of open files
      { domain = "*"; type = "soft"; item = "nofile"; value = "4096"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "8192"; }
    ];
  };

  # ===== Filesystem Security =====
  # Set secure umask (new files created with 0027 permissions)
  security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "umask"; value = "0027"; }
  ];

  # Mount /tmp with noexec, nosuid, nodev
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=1777" "strictatime" "nosuid" "nodev" "noexec" "size=4G" ];
  };

  # ===== ClamAV Antivirus =====
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    updater.frequency = 24;  # Update virus definitions every 24 hours
  };

  # ===== System-Monitoring und Security Auditing =====
  environment.systemPackages = with pkgs; [
    osquery            # System-Monitoring Framework
    apparmor-utils     # AppArmor CLI-Tools
    usbguard           # USB-Device Management
    usbguard-notifier  # Desktop Benachrichtigungen für USB
    lynis              # Security auditing tool
    chkrootkit         # Rootkit detection
    rkhunter           # Rootkit hunter
    aide               # File integrity checker
  ];

  # ===== Additional Security Measures =====
  # Disable coredumps
  systemd.coredump.enable = false;
  security.pam.services.su.forwardXAuth = false;

  # Restrict access to /proc
  boot.specialFileSystems."/proc".options = [ "hidepid=2" ];

  # Enable protective features
  security.protectKernelImage = true;
  security.forcePageTableIsolation = true;

  # Restrict ptrace to root only (hardened)
  security.allowUserNamespaces = true;  # Needed for containers

  # Disable unnecessary protocols
  boot.blacklistedKernelModules = [
    "bluetooth"     # Comment out if you need Bluetooth
    "btusb"
    "uvcvideo"      # Webcam - comment out if needed
    # Uncommon network protocols
    "dccp"
    "sctp"
    "rds"
    "tipc"
  ];
}