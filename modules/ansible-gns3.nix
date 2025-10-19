{ config, pkgs, ... }:

{
  # ===== GNS3 Umgebung =====
  environment.systemPackages = with pkgs; [
    # GNS3 Core
    gns3-server
    gns3-gui
    
    # Network Emulation Tools
    dynamips          # Cisco Router Emulator
    vpcs              # Virtual PC Simulator
    ubridge           # Network Bridge Tool
    
    # Ansible Ecosystem
    ansible           # Automation Tool
    ansible-lint      # Best Practices Linter
    
    # Python für Ansible & GNS3 API
    python312
    python312Packages.pip
    python312Packages.netmiko      # Multi-vendor SSH Library
    python312Packages.jinja2       # Template Engine
    python312Packages.paramiko     # SSH für Ansible
    python312Packages.requests     # HTTP Library für GNS3 API
    
    # Network Testing & Debugging
    nmap              # Network Scanner
    netcat            # TCP/UDP Debugging
    tcpdump           # Packet Analyzer
    iperf3            # Network Performance
    mtr               # Network Diagnostics
  ];

  # ===== Netzwerk-Konfiguration =====
  networking.firewall = {
    enable = true;
    
    # GNS3 Ports
    allowedTCPPorts = [
      3080          # GNS3 Server HTTP API
      3081          # GNS3 Server WebSocket (Computing)
      8000          # Alternative GNS3 Port
      
      # Ansible & SSH
      22            # SSH für Ansible
      
      # Telnet für alte Router (optional)
      23            # Telnet
    ];
    
    allowedUDPPorts = [
      5000          # GNS3 Console Range Start
      10000         # GNS3 Console Range End
    ];
    
    # Erlaube GNS3 Console Port Range
    allowedTCPPortRanges = [
      { from = 5000; to = 10000; }  # GNS3 Console Ports
    ];
  };

  # ===== uBridge Capabilities =====
  # Erlaubt uBridge, Netzwerk-Bridges ohne Root zu erstellen
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "root";
  };

  # uBridge sudo ohne Passwort
  security.sudo.extraRules = [{
    users = [ "user" ];
    commands = [{
      command = "${pkgs.ubridge}/bin/ubridge";
      options = [ "NOPASSWD" ];
    }];
  }];

  # ===== QEMU/KVM für GNS3 VMs =====
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };

  # User zur libvirtd Gruppe
  users.users.user.extraGroups = [ "libvirtd" "wireshark" ];

  # ===== Wireshark ohne Root =====
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # ===== Ansible Konfiguration =====
  environment.etc."ansible/ansible.cfg".text = ''
    [defaults]
    # Basis-Einstellungen
    inventory = /home/user/ansible/inventory
    roles_path = /home/user/ansible/roles
    host_key_checking = False
    retry_files_enabled = False
    gathering = smart
    fact_caching = jsonfile
    fact_caching_connection = /tmp/ansible_facts
    fact_caching_timeout = 3600
    
    # Output
    stdout_callback = yaml
    callback_whitelist = profile_tasks, timer
    
    # SSH Verbindungen
    timeout = 30
    connect_timeout = 30
    command_timeout = 30
    
    # Für Network Devices
    [persistent_connection]
    connect_timeout = 60
    command_timeout = 60
  '';

  # ===== GNS3 Server Konfiguration =====
  environment.etc."gns3/gns3_server.conf".text = ''
    [Server]
    host = 0.0.0.0
    port = 3080
    path = /home/user/GNS3
    images_path = /home/user/GNS3/images
    projects_path = /home/user/GNS3/projects
    additional_images_paths = 
    report_errors = True
    
    [Dynamips]
    allocate_aux_console_ports = False
    mmap_support = True
    sparse_memory_support = True
    ghost_ios_support = True
    
    [IOU]
    iourc_path = /home/user/GNS3/iourc
    license_check = False
    
    [Qemu]
    enable_kvm = True
    require_kvm = True
  '';

  # ===== Systemd Service für GNS3 Server =====
  systemd.services.gns3-server = {
    description = "GNS3 Network Simulator Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "user";
      ExecStart = "${pkgs.gns3-server}/bin/gns3server";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # ===== GNS3 Verzeichnisse erstellen =====
  system.activationScripts.gns3dirs = ''
    mkdir -p /home/user/GNS3/{projects,images,appliances}
    mkdir -p /home/user/ansible/{playbooks,inventory,roles,templates,group_vars,host_vars}
    chown -R user:users /home/user/GNS3
    chown -R user:users /home/user/ansible
  '';

  # ===== Python Virtual Environment für GNS3 API =====
  # Ermöglicht pip install ohne Konflikte
  environment.shellInit = ''
    # GNS3 Python Umgebung
    export GNS3_SERVER_HOST="localhost"
    export GNS3_SERVER_PORT="3080"
    
    # Ansible Umgebung
    export ANSIBLE_HOME="/home/user/ansible"
    export ANSIBLE_CONFIG="/etc/ansible/ansible.cfg"
  '';

  # ===== Nützliche Aliases =====
  environment.shellAliases = {
    # GNS3
    gns3-start = "systemctl start gns3-server";
    gns3-stop = "systemctl stop gns3-server";
    gns3-status = "systemctl status gns3-server";
    gns3-logs = "journalctl -u gns3-server -f";
    
    # Ansible
    ap = "ansible-playbook";
    av = "ansible-vault";
    ag = "ansible-galaxy";
    ai = "ansible-inventory";
    
    # Network Testing
    netscan = "nmap -sn";
  };
}