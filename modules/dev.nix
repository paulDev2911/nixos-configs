{ config, pkgs, ... }:

{
  # Development environment configuration
  # All development tools, languages, and build systems

  environment.systemPackages = with pkgs; [
    # ===== Python Development =====
    python3Full              # Python 3 with full standard library
    python3Packages.pip      # Python package installer
    python3Packages.virtualenv
    python3Packages.setuptools
    python3Packages.wheel

    # Common Python development packages
    python3Packages.requests
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.pytest
    python3Packages.black    # Code formatter
    python3Packages.flake8   # Linter
    python3Packages.pylint

    # ===== Version Control =====
    git
    git-lfs                  # Large file storage
    gitui                    # TUI for git
    gh                       # GitHub CLI

    # ===== Build Tools & Compilers =====
    gcc                      # GNU C compiler
    gnumake                  # GNU Make
    cmake                    # Cross-platform build system
    ninja                    # Small build system
    pkg-config              # Helper tool for compiling

    # ===== Node.js / JavaScript =====
    nodejs_22                # Node.js runtime
    nodePackages.npm         # Node package manager
    nodePackages.yarn        # Alternative package manager
    nodePackages.pnpm        # Fast package manager

    # ===== Container & Virtualization Dev Tools =====
    docker-compose           # Multi-container Docker apps
    kubectl                  # Kubernetes CLI
    podman-compose          # Podman compose

    # ===== Database Tools =====
    sqlite                   # Lightweight database
    postgresql              # PostgreSQL client
    mysql-client            # MySQL/MariaDB client

    # ===== Network & API Development =====
    curl                     # Command line HTTP client
    wget                     # File downloader
    httpie                   # User-friendly HTTP client
    postman                 # API development platform
    insomnia                # REST/GraphQL client
    wireshark               # Network protocol analyzer
    tcpdump                 # Network packet capture
    nmap                    # Network scanner

    # ===== Text Editors & IDEs =====
    vscodium                # VSCode without telemetry
    vim                      # Terminal text editor
    neovim                  # Improved Vim

    # ===== Debugging & Profiling =====
    gdb                      # GNU Debugger
    valgrind                # Memory debugging tool
    strace                  # System call tracer
    ltrace                  # Library call tracer

    # ===== Code Analysis & Formatting =====
    shellcheck              # Shell script linter
    shfmt                   # Shell script formatter
    nixfmt-rfc-style        # Nix code formatter

    # ===== Documentation =====
    man-pages               # Linux manual pages
    man-pages-posix        # POSIX manual pages

    # ===== Terminal Utilities =====
    tmux                    # Terminal multiplexer
    screen                  # Terminal multiplexer alternative
    ripgrep                 # Fast grep alternative
    fd                      # Fast find alternative
    eza                     # Modern ls replacement
    bat                     # Cat with syntax highlighting
    fzf                     # Fuzzy finder
    jq                      # JSON processor
    yq                      # YAML processor

    # ===== Monitoring & System Tools =====
    htop                    # Process viewer
    btop                    # Resource monitor
    ncdu                    # Disk usage analyzer
    iotop                   # I/O monitor

    # ===== Rust Development =====
    rustc                   # Rust compiler
    cargo                   # Rust package manager
    rustfmt                 # Rust formatter
    clippy                  # Rust linter

    # ===== Other Languages =====
    lua                     # Lua interpreter
    ruby                    # Ruby interpreter
    perl                    # Perl interpreter

    # ===== Documentation Generators =====
    doxygen                 # Documentation generator
    graphviz               # Graph visualization

    # ===== Archive Tools =====
    zip
    unzip
    p7zip

    # ===== Performance Analysis =====
    linuxPackages.perf                    # Linux performance tools
    flamegraph             # Flame graph visualization
  ];

  # Enable Docker for containerized development
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Enable Podman as Docker alternative
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Git global configuration
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Fish shell for better developer experience (optional)
  programs.fish.enable = true;

  # Zsh with oh-my-zsh (optional alternative)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Development-related environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PYTHONDONTWRITEBYTECODE = "1";  # Don't create __pycache__
  };

  # Enable man pages with search capability
  documentation = {
    enable = true;
    dev.enable = true;      # Install development documentation
    man.enable = true;
    info.enable = true;
  };
}
