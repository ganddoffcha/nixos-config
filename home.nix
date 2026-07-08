{ config, lib, pkgs, ... }:

let
  # Stylix colour palette — used for BEMENU_OPTS and home-manager activation.
  # Note: app config colours are now handled imperatively at runtime by
  # ~/scripts/theme for instant switching without nixos-rebuild.
  palette = config.lib.stylix.colors.withHashtag;
in {
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
    brave
    qutebrowser

    # ── Terminals ───────────────────────────────────────────────────────
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
    scx.full
    eza
    bat
    ripgrep
    jq
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
    ouch
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
    wdisplays
    wlr-randr
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
    # ── Documents ───────────────────────────────────────────────────────
    texlive.combined.scheme-full
    zathura

    # ── Music ───────────────────────────────────────────────────────────
    musescore
    muse-sounds-manager

    # ── Network ─────────────────────────────────────────────────────────
    speedtest-cli
    wireguard-tools

    # ── Development ─────────────────────────────────────────────────────
    git
    gh
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
  # CURSOR — managed declaratively instead of manual ~/.local/share/icons
  # ═══════════════════════════════════════════════════════════════════════
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # STYLIX TARGETS — apply Catppuccin Mocha to apps with native HM modules
  # (hyprland, waybar, kitty, ghostty, bemenu, mako themed manually via
  #  dotfiles — see ./dotfiles/<app>/)
  # ═══════════════════════════════════════════════════════════════════════
  stylix.targets = {
    gtk.enable = true;
    starship.enable = true;
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
      monospace = [ "Google Sans Mono" "Shanggu Mono" ];
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
    settings = {
      user.name = "gc";
      user.email = "gc@zephyrus";
      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "delta";
      delta.navigate = true;
      delta.side-by-side = true;
      delta.line-numbers = true;
      delta.syntax-theme = "catppuccin-mocha";
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
    profileExtra = ''
      # Start Hyprland via uwsm (Wayland session manager)
      uwsm check may-start && uwsm start hyprland-uwsm.desktop
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
    # bemenu launcher colours (dynamic — follows current theme at login).
    # Runtime theme changes are handled by ~/scripts/theme which writes
    # ~/.config/bemenu/env and the bemenu/bemenu-run wrappers which source it.
    # -W 1.0 = full width (matching waybar). --fn + -H match waybar height.
    BEMENU_OPTS = "--tb=${palette.base01} --tf=${palette.base05} --fb=${palette.base01} --ff=${palette.base05} --nb=${palette.base01} --nf=${palette.base05} --hb=${palette.base03} --hf=${palette.base0A} --sb=${palette.base03} --sf=${palette.base0B} --scb=${palette.base00} --scf=${palette.base03} -W 1.0 --fn 'Google Sans 10' -H 22 -B 0";
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
  #
  # Config files with {{base00}}…{{base0F}} placeholders are NOT managed
  # by home-manager — they're generated at runtime by ~/scripts/theme
  # for instant theme switching without nixos-rebuild.

  # ── Hyprland ──────────────────────────────────────────────────────────
  # hyprland.conf — themed at runtime by ~/scripts/theme (imperative colours)
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
  # AC power config — no idle actions at all. Screen stays on indefinitely.
  xdg.configFile."hypr/hypridle-ac.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = ${pkgs.systemd}/bin/loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }
  '';
  xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hypr/hyprlock.conf;
  # hyprpaper.conf — managed at runtime by ~/scripts/wallpaper (wallpaper paths change)

  # ── Notifications ─────────────────────────────────────────────────────
  # mako/config — themed at runtime by ~/scripts/theme (imperative colours)

  # ── Waybar ────────────────────────────────────────────────────────────
  xdg.configFile."waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
  # waybar/style.css — themed at runtime by ~/scripts/theme (imperative colours)

  # ── Terminal ──────────────────────────────────────────────────────────
  # ghostty/config — themed at runtime by ~/scripts/theme (imperative colours)
  # kitty/kitty.conf — themed at runtime by ~/scripts/theme (imperative colours)

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
  home.file."scripts/bemenu-run" = {
    source = ./dotfiles/scripts/bemenu-run;
    executable = true;
  };
  home.file."scripts/bemenu" = {
    source = ./dotfiles/scripts/bemenu;
    executable = true;
  };
  home.file."scripts/wallpaper" = {
    source = ./dotfiles/scripts/wallpaper;
    executable = true;
  };
  home.file."scripts/theme" = {
    source = ./dotfiles/scripts/theme;
    executable = true;
  };
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
  # nvim/colors/base16-stylix.vim — themed at runtime by ~/scripts/theme (imperative colours)
  xdg.configFile."qutebrowser/config.py".source = ./dotfiles/qutebrowser/config.py;
  xdg.configFile."yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  # yazi/theme.toml — themed at runtime by ~/scripts/theme (imperative colours)
  xdg.configFile."zathura/zathurarc".source = ./dotfiles/zathura/zathurarc;
  xdg.configFile."mpv/mpv.conf".source = ./dotfiles/mpv/mpv.conf;

  # ── MIME associations ──────────────────────────────────────────────────
  xdg.configFile."mimeapps.list".source = ./dotfiles/mimeapps.list;

  # ── Default application handlers — generated from Nix, no raw files ────
  xdg.desktopEntries = {
    # ── Terminal-based handlers (ghostty wrapper needed because
    # NixOS xdg-open does not respect Terminal=true in .desktop files) ────
    text = {
      name = "Text editor";
      exec = "ghostty -e nvim %F";
      mimeType = [ "text/plain" "text/x-shellscript" "text/markdown" "text/x-makefile" "text/x-csrc" "text/x-python" ];
      noDisplay = true;
    };
    file = {
      name = "File manager";
      exec = "ghostty -e yazi %F";
      mimeType = [ "inode/directory" "application/zip" "application/x-tar" "application/gzip" "application/x-xz" "application/x-7z-compressed" "application/x-rar" "application/x-bzip2" ];
      noDisplay = true;
    };
  };
  # Images use package imv.desktop (%F, 15 MIME types)
  # PDF/EPUB/comics use package org.pwmt.zathura-pdf-mupdf.desktop

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
      ExecStart = "${pkgs.hypridle}/bin/hypridle -c %h/.config/hypr/hypridle-active.conf";
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
    # Cache the base16-schemes path so the theme preview script is instant
    cacheBase16Path = ''
      mkdir -p "$HOME/.cache"
      echo "${pkgs.base16-schemes}/share/themes" > "$HOME/.cache/base16-themes-path"
    '';
    # Generate themed configs on activation (first install / rebuild).
    # Inline logic avoids chicken-and-egg: ~/scripts/theme symlink isn't
    # updated yet during activation, so we can't call it directly.
    generateThemedConfigs = ''
      THEME_FILE="$HOME/dotfiles/current-theme"
      THEME=$(${pkgs.coreutils}/bin/cat "$THEME_FILE" 2>/dev/null || echo "google-dark")
      YAML="${pkgs.base16-schemes}/share/themes/$THEME.yaml"
      if [ ! -f "$YAML" ]; then
        echo "theme: '$THEME' not found, skipping config generation" >&2
        exit 0
      fi
      # Parse base16 YAML → 16 hex colours
      ${pkgs.python3}/bin/python3 -c '
import sys, re
with open("'"$YAML"'") as f:
    text = f.read()
for i in range(16):
    m = re.search(r"(?i)^\s*base%02x:\s*\"?#?([0-9a-fA-F]{6})\"?" % i, text, re.MULTILINE)
    print(m.group(1) if m else "ffffff")
' > /tmp/theme-colors.txt
      # Read colours into array
      colors=()
      while IFS= read -r hex; do colors+=("$hex"); done < /tmp/theme-colors.txt
      rm -f /tmp/theme-colors.txt
      if [ ''${#colors[@]} -ne 16 ]; then
        echo "theme: failed to parse colours from $YAML" >&2
        exit 0
      fi
      # Substitute and write configs
      sub() {
        local c="$1"
        for i in $(seq 0 15); do
          local hex="''${colors[$i]}"
          local key_lower; key_lower=$(printf 'base%02x' "$i")
          local key_upper; key_upper=$(printf 'base%02X' "$i")
          c="''${c//"{{$key_lower}}"/#''${hex}}"
          c="''${c//"{{$key_upper}}"/#''${hex}}"
          c="''${c//"{{x$key_lower}}"/''${hex}}"
          c="''${c//"{{x$key_upper}}"/''${hex}}"
        done
        echo "$c"
      }
      write_config() {
        local src="$1" dst="$2"
        mkdir -p "$(dirname "$dst")"
        sub "$(${pkgs.coreutils}/bin/cat "$src")" > "$dst"
      }
      # Remove old Nix store symlinks first (they're read-only).
      # Atomic writes: .tmp then mv prevents the file-ever-missing gap
      # that triggers Hyprland's autogenerated-config fallback.
      atomic_write() {
        local src="$1" dst="$2"
        mkdir -p "$(dirname "$dst")"
        sub "$(${pkgs.coreutils}/bin/cat "$src")" > "$dst.tmp"
        mv "$dst.tmp" "$dst"
      }
      atomic_write "$HOME/dotfiles/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
      atomic_write "$HOME/dotfiles/mako/config" "$HOME/.config/mako/config"
      atomic_write "$HOME/dotfiles/waybar/style.css" "$HOME/.config/waybar/style.css"
      atomic_write "$HOME/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"
      atomic_write "$HOME/dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
      atomic_write "$HOME/dotfiles/nvim/colors/base16-stylix.vim" "$HOME/.config/nvim/colors/base16-stylix.vim"
      atomic_write "$HOME/dotfiles/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
      # Also generate bemenu env so wrappers pick up theme colours
      mkdir -p "$HOME/.config/bemenu"
      # Bootstrap hypridle-active.conf on first install / after rebuild
      if [ ! -f "$HOME/.config/hypr/hypridle-active.conf" ]; then
        mkdir -p "$HOME/.config/hypr"
        ${pkgs.coreutils}/bin/cp "$HOME/.config/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle-active.conf"
      fi
      cat > "$HOME/.config/bemenu/env" <<BEMENU_EOF
# Generated by home-manager activation — do not edit
BEMENU_OPTS="--tb=#''${colors[1]} --tf=#''${colors[5]} --fb=#''${colors[1]} --ff=#''${colors[5]} --nb=#''${colors[1]} --nf=#''${colors[5]} --hb=#''${colors[3]} --hf=#''${colors[10]} --sb=#''${colors[3]} --sf=#''${colors[11]} --scb=#''${colors[0]} --scf=#''${colors[3]} -W 1.0 --fn 'Google Sans 10' -H 22 -B 0"
BEMENU_EOF
      echo "theme: generated configs for '$THEME'"
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════
  # SELF-MANAGEMENT
  # ═══════════════════════════════════════════════════════════════════════
  programs.home-manager.enable = true;
}
