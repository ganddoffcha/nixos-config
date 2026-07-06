{ config, pkgs, ... }:

{
  # Allow unfree packages (vscode, spotify, etc.)
  nixpkgs.config.allowUnfree = true;

  home.username = "gc";
  home.homeDirectory = "/home/gc";
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;

  # ═══════════════════════════════════════════════════════════════════════
  # PACKAGES — user-facing applications & tools
  # ═══════════════════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # ── Data Science ────────────────────────────────────────────────────
    R
    rPackages.dplyr
    rPackages.nycflights13

    # ── Editors ─────────────────────────────────────────────────────────
    neovim
    vscode

    # ── Browsers ────────────────────────────────────────────────────────
    chromium
    brave
    qutebrowser

    # ── Terminals ───────────────────────────────────────────────────────
    alacritty
    kitty
    ghostty

    # ── Shell Tools ─────────────────────────────────────────────────────
    zsh-fast-syntax-highlighting
    starship
    zoxide
    fzf
    fd
    tree
    wget
    direnv

    # ── System Monitoring ───────────────────────────────────────────────
    htop
    fastfetch
    inxi
    powertop
    psmisc

    # ── File Management ─────────────────────────────────────────────────
    yazi
    unzip
    zip
    gzip
    poppler-utils
    pdftk

    # ── Hyprland / Wayland ──────────────────────────────────────────────
    waybar
    mako
    gammastep
    hyprpaper
    hyprpicker
    hyprpolkitagent
    wofi
    bemenu
    slurp
    grim
    wl-clipboard
    wf-recorder
    brightnessctl
    libnotify

    # ── Media ───────────────────────────────────────────────────────────
    spotify
    mpv
    imv
    yt-dlp
    playerctl
    pulsemixer
    cheese
    obs-studio
    openai-whisper

    # ── Graphics ────────────────────────────────────────────────────────
    gimp3
    imagemagick
    inkscape

    # ── Documents ───────────────────────────────────────────────────────
    texlive.combined.scheme-full
    zathura
    kdePackages.okular
    libreoffice-qt6-fresh

    # ── Music ───────────────────────────────────────────────────────────
    musescore
    muse-sounds-manager

    # ── Gaming ──────────────────────────────────────────────────────────
    prismlauncher
    stockfish
    gnuchess
    pychess
    cutechess
    lc0
    xboard
    ckan

    # ── Network ─────────────────────────────────────────────────────────
    speedtest-cli
    wireguard-tools
    gnome-network-displays

    # ── Development ─────────────────────────────────────────────────────
    git
    python3
    elan
    openssl
    nss
    nssTools
    clinfo

    # ── Messaging ───────────────────────────────────────────────────────
    telegram-desktop

    # ── Fun ─────────────────────────────────────────────────────────────
    cmatrix

    # ── Fonts ───────────────────────────────────────────────────────────
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    shanggu-fonts
  ];

  # ═══════════════════════════════════════════════════════════════════════
  # FONTS
  # ═══════════════════════════════════════════════════════════════════════
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Google Sans" "Shanggu Sans" ];
      serif = [ "Shanggu Serif" ];
      monospace = [ "Google Sans Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # GIT
  # ═══════════════════════════════════════════════════════════════════════
  programs.git = {
    enable = true;
    userName = "gc";
    userEmail = "gc@zephyrus";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # SHELL — Zsh with plugins
  # ═══════════════════════════════════════════════════════════════════════
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initContent = ''
      # zoxide — smarter cd
      eval "$(zoxide init zsh)"

      # starship prompt
      eval "$(starship init zsh)"

      # fzf
      eval "$(fzf --zsh)"

      # direnv
      eval "$(direnv hook zsh)"
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════
  # STARSHIP
  # ═══════════════════════════════════════════════════════════════════════
  programs.starship = {
    enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # DIRENV
  # ═══════════════════════════════════════════════════════════════════════
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # ENVIRONMENT
  # ═══════════════════════════════════════════════════════════════════════
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    BROWSER = "brave";
  };

  # ═══════════════════════════════════════════════════════════════════════
  # DOTFILES — declaratively managed config files
  # ═══════════════════════════════════════════════════════════════════════
  # Each entry symlinks a file from ./dotfiles/ into ~/.config/ or ~/.
  # On a new machine, just clone the dotfiles repo and rebuild.

  # ── Hyprland ──────────────────────────────────────────────────────────
  xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/hypr/hyprpaper.conf;

  # ── Waybar ────────────────────────────────────────────────────────────
  xdg.configFile."waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./dotfiles/waybar/style.css;

  # ── Terminal ──────────────────────────────────────────────────────────
  xdg.configFile."ghostty/config".source = ./dotfiles/ghostty/config;

  # ── Screen color temperature ──────────────────────────────────────────
  xdg.configFile."gammastep/config.ini".source = ./dotfiles/gammastep/config.ini;

  # ── VSCode ────────────────────────────────────────────────────────────
  xdg.configFile."Code/User/keybindings.json".source = ./dotfiles/Code/User/keybindings.json;

  # ── Workspace root files ──────────────────────────────────────────────
  home.file.".clinerules".source = ./dotfiles/clinerules;
  home.file."memory-strategy.md".source = ./dotfiles/memory-strategy.md;

  # ── Scripts ───────────────────────────────────────────────────────────
  home.file."scripts/zoo".source = ./dotfiles/scripts/zoo;
  home.file."scripts/compiler".source = ./dotfiles/scripts/compiler;
  home.file."scripts/getcomproot".source = ./dotfiles/scripts/getcomproot;
  home.file."scripts/hotspot".source = ./dotfiles/scripts/hotspot;
  home.file."scripts/opout".source = ./dotfiles/scripts/opout;
  home.file."scripts/sp".source = ./dotfiles/scripts/sp;
  home.file."scripts/texnow".source = ./dotfiles/scripts/texnow;
  home.file."scripts/toggle_touchpad".source = ./dotfiles/scripts/toggle_touchpad;
  home.file."scripts/yazi_picker".source = ./dotfiles/scripts/yazi_picker;

  # ── App configs ───────────────────────────────────────────────────────
  xdg.configFile."nvim/init.vim".source = ./dotfiles/nvim/init.vim;
  xdg.configFile."yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  xdg.configFile."zathura/zathurarc".source = ./dotfiles/zathura/zathurarc;
  xdg.configFile."htop/htoprc".source = ./dotfiles/htop/htoprc;

  # ═══════════════════════════════════════════════════════════════════════
  # POWER MANAGEMENT — auto-switch compositor settings on AC state change
  # ═══════════════════════════════════════════════════════════════════════
  home.file."scripts/auto-refresh.sh" = {
    source = ./dotfiles/scripts/auto-refresh.sh;
    executable = true;
  };
  home.file."scripts/rebuild" = {
    source = ./dotfiles/scripts/rebuild;
    executable = true;
  };

  systemd.user.services.auto-refresh = {
    Unit = {
      Description = "Auto-switch power profile based on AC status";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/scripts/auto-refresh.sh";
    };
  };

  systemd.user.timers.auto-refresh = {
    Unit = {
      Description = "Auto-refresh power profile poller";
    };
    Timer = {
      OnActiveSec = "2s";
      OnUnitActiveSec = "5s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # SELF-MANAGEMENT
  # ═══════════════════════════════════════════════════════════════════════
  programs.home-manager.enable = true;
}
