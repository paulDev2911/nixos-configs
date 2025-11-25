{ config, pkgs, ... }:

{
  #===== Salt Stack Configuration =====
  #Salt Master for managing homelab infrastructure
  #Salt Minion for local management

  environment.systemPackages = with pkgs; [
    #Salt Stack
    salt                    #Salt Master & Minion
    
    #Salt Utilities
    python312Packages.salt  #Python Salt modules
    python312Packages.jinja2 #Template engine for Salt states
    python312Packages.pyyaml #YAML parsing
    python312Packages.msgpack #MessagePack serialization
    python312Packages.pyzmq  #ZeroMQ bindings
    python312Packages.tornado #Async networking library
    python312Packages.requests #HTTP library
  ];

  #===== Salt Master Service =====
  services.salt.master = {
    enable = true;
    configuration = ''
      #===== Interface & Network =====
      interface: 0.0.0.0
      publish_port: 4505
      ret_port: 4506
      
      #===== Security =====
      auto_accept: False          #Manually accept minion keys for security
      
      #===== File Locations =====
      file_roots:
        base:
          - /srv/salt/states
          - /srv/salt/formulas
      
      pillar_roots:
        base:
          - /srv/pillar
      
      #===== Performance =====
      worker_threads: 5
      timeout: 10
      gather_job_timeout: 10
      
      #===== Logging =====
      log_level: info
      log_file: /var/log/salt/master
      
      #===== File Server =====
      fileserver_backend:
        - roots
      
      #===== State System =====
      state_top: top.sls
      state_output: mixed
      state_verbose: False
    '';
  };

  #===== Salt Minion Service (for local management) =====
  services.salt.minion = {
    enable = true;
    configuration = ''
      #===== Master Configuration =====
      master: localhost
      
      #===== Minion Identity =====
      id: nixos-laptop
      
      #===== Logging =====
      log_level: info
      log_file: /var/log/salt/minion
      
      #===== Performance =====
      acceptance_wait_time: 10
      acceptance_wait_time_max: 60
      random_reauth_delay: 10
      recon_default: 100
      recon_max: 5000
      recon_randomize: True
      
      #===== Grains (system info) =====
      grains:
        roles:
          - laptop
          - salt-master
        environment: homelab
    '';
  };

  #===== Firewall Configuration =====
  networking.firewall = {
    allowedTCPPorts = [
      4505  #Salt Publisher Port (Master → Minions)
      4506  #Salt Request Server Port (Minions → Master)
    ];
  };

  #===== Salt Directories =====
  systemd.tmpfiles.rules = [
    "d /srv/salt 0755 root root -"
    "d /srv/salt/states 0755 root root -"
    "d /srv/salt/formulas 0755 root root -"
    "d /srv/pillar 0700 root root -"
    "d /var/log/salt 0755 root root -"
  ];

  #===== Environment Variables =====
  environment.variables = {
    SALT_MASTER = "localhost";
  };

  #===== Shell Aliases =====
  environment.shellAliases = {
    salt-key-list = "sudo salt-key -L";
    salt-key-accept = "sudo salt-key -a";
    salt-ping = "sudo salt '*' test.ping";
    salt-state = "sudo salt '*' state.apply";
  };
}