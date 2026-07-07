{ config, lib, pkgs, ... }:

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
    starship
    zoxide
    fzf
    fd
    wget
    direnv
    dash

    # ── Modern CLI Tools ─────────────────────────────────────────────────
    eza
    bat
    ripgrep
    dust
    delta
    bottom
    atuin
    lazygit
    tealdeer
    nodejs
    procs
    xh
    zellij
    vivid

    # ── System Monitoring ───────────────────────────────────────────────
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
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    bibata-cursors
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

    # ── Development ─────────────────────────────────────────────────────
    git
    gh
    python3
    elan
    emacs
    tree-sitter
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
  # CURSOR — managed declaratively instead of manual ~/.local/share/icons
  # ═══════════════════════════════════════════════════════════════════════
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # FONTS
  # ═══════════════════════════════════════════════════════════════════════
  fonts.fontconfig = {
    enable = true;
    # Rendering — tuned for 2560×1600 @ 186 DPI LCD panel
    hinting = "slight";
    # Font families
    defaultFonts = {
      sansSerif = [ "Google Sans" "Shanggu Sans" ];
      serif = [ "Shanggu Serif" ];
      monospace = [ "Google Sans Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # ── Google Sans fonts (installed to ~/.local/share/fonts/) ─────────────
  xdg.dataFile."fonts/Google-Sans/GoogleSans-Bold.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-Bold.ttf;
  xdg.dataFile."fonts/Google-Sans/GoogleSans-BoldItalic.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-BoldItalic.ttf;
  xdg.dataFile."fonts/Google-Sans/GoogleSans-Italic.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-Italic.ttf;
  xdg.dataFile."fonts/Google-Sans/GoogleSans-Medium.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-Medium.ttf;
  xdg.dataFile."fonts/Google-Sans/GoogleSans-MediumItalic.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-MediumItalic.ttf;
  xdg.dataFile."fonts/Google-Sans/GoogleSans-Regular.ttf".source = ./dotfiles/fonts/Google-Sans/GoogleSans-Regular.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Bold.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Bold.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Italic.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Italic.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-Bold.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-Bold.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-Medium.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-Medium.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-SemiBold.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Italic-SemiBold.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Medium.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Medium.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-Regular.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-Regular.ttf;
  xdg.dataFile."fonts/Google-Sans-Mono/Google-Sans-Mono-SemiBold.ttf".source = ./dotfiles/fonts/Google-Sans-Mono/Google-Sans-Mono-SemiBold.ttf;

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
      core.pager = "delta";
      delta.navigate = true;
      delta.side-by-side = true;
      delta.line-numbers = true;
      delta.syntax-theme = "Dracula";
      interactive.diffFilter = "delta --color-only";
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
    syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" ];
    syntaxHighlighting.styles = {
      command = "fg=#00ff00,bold";
      builtin = "fg=#00ff00";
      alias = "fg=#00ffff,bold";
      function = "fg=#0055ff,bold";
      "unknown-token" = "fg=#ff0000,bold";
      path = "fg=#ffffff,underline";
      globbing = "fg=#ffff00";
      "history-expansion" = "fg=#0055ff";
      "single-quoted-argument" = "fg=#ffff00";
      "double-quoted-argument" = "fg=#ffff00";
      "dollar-quoted-argument" = "fg=#ffff00";
      comment = "fg=#555555,bold";
      redirection = "fg=#ff00ff";
      default = "none";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initContent = ''
      # ── Aliases: modern replacements ─────────────────────────────────
      alias ls="eza --icons --group-directories-first"
      alias ll="eza -l --icons --group-directories-first --git"
      alias la="eza -la --icons --group-directories-first --git"
      alias lt="eza --tree --icons --level=2"
      alias cat="bat --paging=never"
      alias grep="rg"
      alias du="dust"
      alias ps="procs"
      alias top="btm"
      alias htop="btm"
      alias curl="xh"

      # ── Colors ──────────────────────────────────────────────────────
      # Less colors (terminal pager)
      export LESS=R
      export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
      export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
      export LESS_TERMCAP_me="$(printf '%b' '[0m')"
      export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
      export LESS_TERMCAP_se="$(printf '%b' '[0m')"
      export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
      export LESS_TERMCAP_ue="$(printf '%b' '[0m')"

      # vivid generates LS_COLORS for colored directory/file listings
      # Must export explicitly — vivid output is raw LS_COLORS value
      export LS_COLORS="$(vivid generate snazzy)"
      export BAT_THEME="Dracula"

      # ── Tool integrations ────────────────────────────────────────────
      # zoxide — smarter cd
      eval "$(zoxide init zsh)"

      # starship, direnv — already initialized by home-manager before initContent
      # fzf
      eval "$(fzf --zsh)"

      # atuin — shell history (must be after starship)
      eval "$(atuin init zsh --disable-up-arrow)"
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
  home.sessionPath = [
    "$HOME/scripts"
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    BROWSER = "brave";
    # XDG compliance — zsh looks for .zshrc here (login shells)
    ZDOTDIR = "${config.xdg.configHome}/zsh";
    # fzf
    FZF_DEFAULT_OPTS = "--layout=reverse --height 40%";
    # less colors
    LESS = "R";
    # QT / Java / Mozilla
    QT_QPA_PLATFORMTHEME = "gtk2";
    MOZ_USE_XINPUT2 = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # Go
    GOPATH = "${config.xdg.dataHome}/go";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    # Cargo
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    # Sudo
    SUDO_ASKPASS = "${config.home.homeDirectory}/.local/bin/dmenupass";
    # XDG compliance — move dotfiles out of ~/
    ZCOMPCACHE = "${config.xdg.cacheHome}/zsh/zcompdump";
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";
    PYTHON_HISTORY = "${config.xdg.dataHome}/python_history";
    # Development tools
    ASDF_DATA_DIR = "${config.xdg.dataHome}/asdf";
    ELAN_HOME = "${config.xdg.dataHome}/elan";
    npm_config_cache = "${config.xdg.cacheHome}/npm";
    MONO_REGISTRY_PATH = "${config.xdg.dataHome}/mono";
    # GPU / driver caches
    CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nvidia";
    __GL_SHADER_CACHE_DIR = "${config.xdg.cacheHome}/nvidia";
    # TeX Live
    TEXMFHOME = "${config.xdg.dataHome}/texmf";
    TEXMFVAR = "${config.xdg.cacheHome}/texlive/texmf-var";
    TEXMFCONFIG = "${config.xdg.configHome}/texlive/texmf-config";
  };

  # ═══════════════════════════════════════════════════════════════════════
  # ZDOTDIR symlink — .zprofile sets ZDOTDIR=~/.config/zsh.
  # Symlink ~/.config/zsh/.zshrc → ~/.zshrc so both login and non-login
  # shells use the same home-manager managed config.
  # ═══════════════════════════════════════════════════════════════════════
  home.file.".config/zsh/.zshrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.zshrc";

  # ── ZDOTDIR .zprofile — login shell only, starts Hyprland via uwsm ─────
  xdg.configFile."zsh/.zprofile".source = ./dotfiles/zsh/.zprofile;

  # ═══════════════════════════════════════════════════════════════════════
  # DOTFILES — declaratively managed config files
  # ═══════════════════════════════════════════════════════════════════════
  # Each entry symlinks a file from ./dotfiles/ into ~/.config/ or ~/.
  # On a new machine, just clone the dotfiles repo and rebuild.

  # ── Hyprland ──────────────────────────────────────────────────────────
  xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = ${pkgs.systemd}/bin/loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
        timeout = 150
        on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -s set 10
        on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -r
    }

    listener {
        timeout = 150
        on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0
        on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight
    }

    listener {
        timeout = 300
        on-timeout = ${pkgs.systemd}/bin/loginctl lock-session
    }

    listener {
        timeout = 330
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r
    }

    listener {
        timeout = 1800
        on-timeout = ${pkgs.systemd}/bin/systemctl suspend
    }
  '';
  xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hypr/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/hypr/hyprpaper.conf;

  # ── Waybar ────────────────────────────────────────────────────────────
  xdg.configFile."waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./dotfiles/waybar/style.css;

  # ── Terminal ──────────────────────────────────────────────────────────
  xdg.configFile."ghostty/config".source = ./dotfiles/ghostty/config;
  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;

  # ── LaTeX ─────────────────────────────────────────────────────────────
  xdg.configFile."latexmk/latexmkrc".source = ./dotfiles/latexmk/latexmkrc;

  # ── Screen color temperature ──────────────────────────────────────────
  xdg.configFile."gammastep/config.ini".source = ./dotfiles/gammastep/config.ini;

  # ── Workspace root files ──────────────────────────────────────────────
  # .clinerules, memory-strategy.md, SYSTEM.md are now real files in ~/
  # (not home-manager symlinks) — same reason as VSCode settings:
  # Nix store symlinks break on garbage collection and are read-only.
  # Source copies live in dotfiles/ for version control.

  # ── Scripts ───────────────────────────────────────────────────────────
  home.file."scripts/compiler".source = ./dotfiles/scripts/compiler;
  home.file."scripts/getcomproot".source = ./dotfiles/scripts/getcomproot;
  home.file."scripts/hotspot".source = ./dotfiles/scripts/hotspot;
  home.file."scripts/opout".source = ./dotfiles/scripts/opout;
  home.file."scripts/sp".source = ./dotfiles/scripts/sp;
  home.file."scripts/texnow".source = ./dotfiles/scripts/texnow;
  home.file."scripts/toggle_touchpad".source = ./dotfiles/scripts/toggle_touchpad;
  home.file."scripts/yazi_picker".source = ./dotfiles/scripts/yazi_picker;
  home.file.".local/bin/dmenupass" = {
    source = ./dotfiles/scripts/dmenupass;
    executable = true;
  };

  # ── App configs ───────────────────────────────────────────────────────
  xdg.configFile."nvim/init.lua".source = ./dotfiles/nvim/init.lua;
  xdg.configFile."nvim/lua/user/options.lua".source = ./dotfiles/nvim/lua/user/options.lua;
  xdg.configFile."nvim/lua/user/keymaps.lua".source = ./dotfiles/nvim/lua/user/keymaps.lua;
  xdg.configFile."nvim/lua/user/autocmds.lua".source = ./dotfiles/nvim/lua/user/autocmds.lua;
  xdg.configFile."nvim/lua/user/plugins.lua".source = ./dotfiles/nvim/lua/user/plugins.lua;
  xdg.configFile."qutebrowser/config.py".source = ./dotfiles/qutebrowser/config.py;
  xdg.configFile."yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  xdg.configFile."zathura/zathurarc".source = ./dotfiles/zathura/zathurarc;
  xdg.configFile."mpv/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
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
      Description = "Auto-refresh power profile poller (fallback)";
    };
    Timer = {
      OnActiveSec = "2s";
      OnUnitActiveSec = "30s";  # udev triggers instant; timer is fallback
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Instant trigger via udev → flag file → path unit
  systemd.user.paths.auto-refresh-instant = {
    Unit = {
      Description = "Watch for power supply changes (udev flag)";
    };
    Path = {
      PathChanged = "/tmp/power-supply-event";
      Unit = "auto-refresh.service";
    };
    Install = {
      WantedBy = [ "paths.target" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # IDLE MANAGEMENT — screen dim, lock, suspend on inactivity
  # ═══════════════════════════════════════════════════════════════════════
  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hypridle idle daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # DESKTOP SERVICES — notification daemon, screen temperature
  # Moved from hyprland exec-once to systemd for declarative reproducibility
  # ═══════════════════════════════════════════════════════════════════════
  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.gammastep = {
    Unit = {
      Description = "Gammastep screen colour temperature";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.gammastep}/bin/gammastep";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # POST-REBUILD — run auto-refresh after home-manager activation so
  # the monitor mode is corrected immediately (Hyprland config reloads
  # during rebuild can reset it to the wrong refresh rate).
  # ═══════════════════════════════════════════════════════════════════════
  home.activation = lib.mkAfter {
    autoRefresh = ''
      if [ -x "$HOME/scripts/auto-refresh.sh" ]; then
        "$HOME/scripts/auto-refresh.sh" || true
      fi
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════
  # SELF-MANAGEMENT
  # ═══════════════════════════════════════════════════════════════════════
  programs.home-manager.enable = true;
}
