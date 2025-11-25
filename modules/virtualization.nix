{ config, pkgs, ... }:

{
  #KVM Intel Optimierungen für bessere VM-Performance
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  #Kernel modules für libvirt/iptables (hardened kernel compatibility)
  boot.kernelModules = [ 
    "kvm-intel"
    "ip_tables"
    "iptable_filter"
    "iptable_nat"
    "xt_REJECT"
    "nf_nat"
    "nf_conntrack"
    "nf_reject_ipv4"
    "nf_reject_ipv6"
  ];

  #dconf für virt-manager GUI-Einstellungen
  programs.dconf.enable = true;

  #uBridge ohne Passwort-Abfrage für User
  security.sudo.extraRules = [{
    users = [ "user" ];
    commands = [{
      command = "${pkgs.ubridge}/bin/ubridge";
      options = [ "NOPASSWD" ];
    }];
  }];

  #User zur libvirtd und docker Gruppe hinzufügen
  users.users.user.extraGroups = [ "libvirtd" "docker" ];

  environment.systemPackages = with pkgs; [
    #Virt-Manager & QEMU/KVM Tools
    virt-manager        #GUI für VM-Verwaltung
    virt-viewer         #VM Display Viewer
    spice               #SPICE Protocol
    spice-gtk           #GTK Integration
    spice-protocol      #Protocol Headers
    win-virtio          #Windows VirtIO Treiber
    win-spice           #Windows SPICE Tools
    
    #Sonstiges
    tigervnc            #VNC Client/Server
    vagrant             #VM Automation Tool
  ];

  virtualisation = {
    #QEMU/KVM Virtualisierung
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;                      #TPM Emulator (für Windows 11)
        ovmf.enable = true;                       #UEFI Support
        ovmf.packages = [ pkgs.OVMFFull.fd ];     #UEFI Firmware
      };
    };
    
    #USB Redirection für VMs
    spiceUSBRedirection.enable = true;
    
    #Docker Container Runtime
    docker.enable = true;
  };

  #WICHTIG: Für libvirt networking
  networking.firewall.checkReversePath = false;

  #SPICE Agent für bessere VM-Integration (Clipboard, Display)
  services.spice-vdagentd.enable = true;
}