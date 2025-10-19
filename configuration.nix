{ config, pkgs, ... }:

{
  # Import modular configuration files
  imports = [
    ./hardware-configuration.nix  # Hardware-specific settings (auto-generated)
    ./modules/services.nix        # System services (SSH, audio, printing)
    ./modules/desktop.nix         # Desktop environment (KDE Plasma)
    ./modules/users.nix           # User account definitions
    ./modules/virtualization.nix
    ./modules/security.nix
    ./modules/ansible-gns3.nix
  ];

  # ===== Boot Configuration =====
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # LUKS disk encryption configuration
  boot.initrd.luks.devices."luks-a15fa5f3-57f6-4597-a9d4-7ccfa2dbb0eb".device = 
    "/dev/disk/by-uuid/a15fa5f3-57f6-4597-a9d4-7ccfa2dbb0eb";

  # ===== Kernel Parameters for Sandbox Fix =====
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };

  # ===== Networking =====
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  # Optional: Configure network proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ===== Localization =====
  # Time zone
  time.timeZone = "Europe/Berlin";
  
  # System language
  i18n.defaultLocale = "de_DE.UTF-8";
  
  # Additional locale settings for German localization
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  
  # Console keyboard layout
  console.keyMap = "de";

  # ===== System Settings =====
  # Allow installation of proprietary software
  nixpkgs.config.allowUnfree = true;

  # ===== Security Settings =====
  # Enable Chromium sandbox for Brave and Electron apps
  security.chromiumSuidSandbox.enable = true;

  # ===== State Version =====
  # DO NOT CHANGE this value after installation!
  # It ensures compatibility with stateful data and services
  # See: https://nixos.org/nixos/options.html
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # default packages
  environment.systemPackages = with pkgs; [
    # Editor
    nano
    
    # Command-line tools
    wget
    git
    htop
    curl
    tree
    
    # VPN & Privacy
    mullvad-vpn
    mullvad-browser
    tor-browser
    
    # Development
    vscodium
    wireshark
    
    # Productivity
    onlyoffice-bin
    thunderbird
    keepassxc
    
    # Browser
    brave

  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d";
  };
}