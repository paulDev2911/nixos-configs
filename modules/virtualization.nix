{ config, pkgs, ... }:

{
  # KVM Intel Optimierungen für bessere VM-Performance
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  # dconf für virt-manager GUI-Einstellungen
  programs.dconf.enable = true;

  # uBridge Capabilities für GNS3 Netzwerk-Simulation
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "root";
  };

  # uBridge ohne Passwort-Abfrage für User "philip"
  security.sudo.extraRules = [{
    users = [ "philip" ];
    commands = [{
      command = "${pkgs.ubridge}/bin/ubridge";
      options = [ "NOPASSWD" ];
    }];
  }];

  environment.systemPackages = with pkgs; [
    # Virt-Manager & QEMU/KVM Tools
    virt-manager        # GUI für VM-Verwaltung
    virt-viewer         # VM Display Viewer
    spice               # SPICE Protocol
    spice-gtk           # GTK Integration
    spice-protocol      # Protocol Headers
    win-virtio          # Windows VirtIO Treiber
    win-spice           # Windows SPICE Tools
    
    # GNS3 Netzwerk-Simulation
    gns3-server         # GNS3 Backend
    gns3-gui            # GNS3 Frontend
    dynamips            # Cisco Router Emulator
    vpcs                # Virtual PC Simulator
    ubridge             # Network Bridge Tool
    
    # Sonstiges
    tigervnc            # VNC Client/Server
    vagrant             # VM Automation Tool
  ];

  virtualisation = {
    # QEMU/KVM Virtualisierung
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;                      # TPM Emulator (für Windows 11)
        ovmf.enable = true;                       # UEFI Support
        ovmf.packages = [ pkgs.OVMFFull.fd ];     # UEFI Firmware
      };
    };
    
    # USB Redirection für VMs
    spiceUSBRedirection.enable = true;
    
    # Docker Container Runtime
    docker.enable = true;
  };

  # SPICE Agent für bessere VM-Integration (Clipboard, Display)
  services.spice-vdagentd.enable = true;
}