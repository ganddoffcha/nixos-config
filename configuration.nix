{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # home-manager and catppuccin are imported via flake.nix
  ];

  # Suppress catppuccin auto-enroll deprecation warning
  catppuccin.autoEnable = true;

  # ═══════════════════════════════════════════════════════════════════════
  # HOME MANAGER — user config lives in home.nix
  # ═══════════════════════════════════════════════════════════════════════
  home-manager.users.gc = {
    imports = [
      ./home.nix
      inputs.catppuccin.homeModules.catppuccin
    ];
  };
  home-manager.backupFileExtension = "backup";

  # ═══════════════════════════════════════════════════════════════════════
  # CONSOLE — Catppuccin Mocha TTY colors
  # ═══════════════════════════════════════════════════════════════════════
  console.colors = [
    "1e1e2e"  # 0  black        (Base)
    "f38ba8"  # 1  red          (Red)
    "a6e3a1"  # 2  green        (Green)
    "f9e2af"  # 3  yellow       (Yellow)
    "89b4fa"  # 4  blue         (Blue)
    "cba6f7"  # 5  magenta      (Mauve)
    "94e2d5"  # 6  cyan         (Teal)
    "cdd6f4"  # 7  white        (Text)
    "45475a"  # 8  bright black (Surface1)
    "f2cdcd"  # 9  bright red   (Flamingo)
    "a6e3a1"  # 10 bright green (Green)
    "fab387"  # 11 bright yellow(Peach)
    "74c7ec"  # 12 bright blue  (Sapphire)
    "f5c2e7"  # 13 bright magent(Pink)
    "89dceb"  # 14 bright cyan  (Sky)
    "b4befe"  # 15 bright white (Lavender)
  ];
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u32n.psf.gz";
  # Use XKB config for virtual console keymap (layout, no swap — keyd handles that)
  console.useXkbConfig = true;

  # ═══════════════════════════════════════════════════════════════════════
  # KEYBOARD — evdev-level remap via keyd (works everywhere: Wayland, X11, TTY, Minecraft)
  # keyd swaps Caps Lock ↔ Escape at the kernel input layer, so ALL apps
  # see the correct keys regardless of whether they respect XKB options.
  # ═══════════════════════════════════════════════════════════════════════
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════════
  # BOOT
  # ═══════════════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;
  boot.loader.timeout = 1;

  # Hibernation — resume from swapfile on root partition
  boot.resumeDevice = "/dev/disk/by-uuid/0e34ea3e-a813-4d7b-8b89-48b78b4fc5a9";

  # Kernel parameters
  #   i8042.reset / kbdreset / atkbd.reset — fix keyboard after suspend/resume
  #   usbcore.autosuspend=-1 — prevent ASUS USB keyboard from disconnecting
  #   pcie_aspm.policy=powersupersave — aggressive PCIe power saving
  #   iwlwifi.power_save=1 — WiFi power saving
  #   i915.enable_guc=3 — enable GuC + HuC firmware for iGPU power management
  #   mem_sleep_default=deep — prefer S3 deep sleep over s2idle
  #   resume_offset=210616320 — physical offset of /swapfile for hibernation
  #   fbcon=nodefer — keep fbcon/fbdev active for TTY framebuffer apps (jfbview, fbterm)
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "nowatchdog"
    "mitigations=off"
    "split_lock_detect=off"
    "i8042.reset=1"
    "i8042.kbdreset=1"
    "atkbd.reset=1"
    "usbcore.autosuspend=-1"
    "iwlwifi.power_save=1"
    "i915.enable_guc=3"
    "mem_sleep_default=deep"
    "resume_offset=210616320"
    "fbcon=nodefer"
  ];

  # Kernel modules — only kvm-intel at boot.
  # nvidia_uvm (and its dependency nvidia.ko) takes 35s to load at boot
  # and is only needed for CUDA workloads — auto-loads on demand.
  boot.kernelModules = lib.mkForce [ "kvm-intel" ];

  # Initrd — zstd decompresses ~4× faster than default on NVMe
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];

  # ═══════════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════════
  networking.hostName = "zephyrus";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Singapore";

  # ═══════════════════════════════════════════════════════════════════════
  # AUDIO
  # ═══════════════════════════════════════════════════════════════════════
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # USERS
  # ═══════════════════════════════════════════════════════════════════════
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.gc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];  # video = /dev/fb0 for fbterm
  };

  # ═══════════════════════════════════════════════════════════════════════
  # FIRMWARE — needed for Intel microcode updates
  # ═══════════════════════════════════════════════════════════════════════
  hardware.enableRedistributableFirmware = true;

  # ═══════════════════════════════════════════════════════════════════════
  # GRAPHICS & NVIDIA
  # ═══════════════════════════════════════════════════════════════════════
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # ── PRIME Offload ─────────────────────────────────────────────────
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # ── Power Management ──────────────────────────────────────────────
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    dynamicBoost.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ═══════════════════════════════════════════════════════════════════════
  # HYPRLAND
  # ═══════════════════════════════════════════════════════════════════════
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # ═══════════════════════════════════════════════════════════════════════
  # LOCATION
  # ═══════════════════════════════════════════════════════════════════════
  services.geoclue2.enable = true;

  # ═══════════════════════════════════════════════════════════════════════
  # EDITOR — disable nano, neovim is in home-manager
  # ═══════════════════════════════════════════════════════════════════════
  programs.nano.enable = false;

  # ═══════════════════════════════════════════════════════════════════════
  # ASUS DAEMON — charge limits, fan curves, platform profiles
  # ═══════════════════════════════════════════════════════════════════════
  services.asusd = {
    enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # THERMAL MANAGEMENT — adaptive CPU throttling for Intel laptops
  # ═══════════════════════════════════════════════════════════════════════
  services.thermald.enable = true;

  # ═══════════════════════════════════════════════════════════════════════
  # TAILSCALE
  # ═══════════════════════════════════════════════════════════════════════
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # ═══════════════════════════════════════════════════════════════════════
  # AUTO UPGRADE — only attempt when plugged in
  # ═══════════════════════════════════════════════════════════════════════
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # PCIe ASPM — performance on AC, powersupersave on battery
  # ═══════════════════════════════════════════════════════════════════════
  services.udev.extraRules = ''
    # AC plugged in → PCIe max performance + trigger refresh
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", \
      RUN+="${pkgs.bash}/bin/bash -c 'echo performance > /sys/module/pcie_aspm/parameters/policy; touch /tmp/power-supply-event; chown gc:users /tmp/power-supply-event'"

    # AC unplugged → PCIe max power saving + trigger refresh
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", \
      RUN+="${pkgs.bash}/bin/bash -c 'echo powersupersave > /sys/module/pcie_aspm/parameters/policy; touch /tmp/power-supply-event; chown gc:users /tmp/power-supply-event'"
  '';

  # ═══════════════════════════════════════════════════════════════════════
  # SWAP — zram (compressed RAM) + disk swap for hibernation
  # ═══════════════════════════════════════════════════════════════════════
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  # ═══════════════════════════════════════════════════════════════════════
  # SYSTEM PACKAGES — minimal; user packages are in home.nix
  # ═══════════════════════════════════════════════════════════════════════
  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = [ "/share/wayland-sessions" ];
  environment.binsh = "${pkgs.dash}/bin/dash";
  environment.systemPackages = with pkgs; [
    # Only packages that are genuinely system-level or needed before
    # home-manager activation. Everything else lives in home.nix.
    curl
    psmisc
    rsync
  ];

  # ═══════════════════════════════════════════════════════════════════════
  # FIREWALL
  # ═══════════════════════════════════════════════════════════════════════
  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  # ═══════════════════════════════════════════════════════════════════════
  # AVAHI (mDNS)
  # ═══════════════════════════════════════════════════════════════════════
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ═══════════════════════════════════════════════════════════════════════
  # FONTS — subpixel rendering at system level, rest in home.nix
  # ═══════════════════════════════════════════════════════════════════════
  fonts.enableDefaultPackages = false;
  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";

  # ═══════════════════════════════════════════════════════════════════════
  # INPUT METHOD
  # ═══════════════════════════════════════════════════════════════════════
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      qt6Packages.fcitx5-chinese-addons
      fcitx5-table-extra
    ];
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # ═══════════════════════════════════════════════════════════════════════
  # SSH
  # ═══════════════════════════════════════════════════════════════════════
  services.openssh.enable = true;

  # ═══════════════════════════════════════════════════════════════════════
  # LOGIND — lid-close → hibernate instead of suspend
  # ═══════════════════════════════════════════════════════════════════════
  services.logind.settings.Login.HandleLidSwitch = "hibernate";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "hibernate";
  services.logind.settings.Login.HandleSuspendKey = "hibernate";

  # ═══════════════════════════════════════════════════════════════════════
  # SERVICE TUNING — delay non-critical services past boot
  # ═══════════════════════════════════════════════════════════════════════

  # nvidia-powerd (1.169s on critical path) — only needed after login
  systemd.services.nvidia-powerd = {
    after = lib.mkForce [ "multi-user.target" ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  # asusd (1.199s on critical path) — fan curves, anime matrix, charge limits.
  # BIOS defaults are fine for the first 3s of graphical session.
  # WantedBy=graphical.target so it starts AFTER login (avoids cycle).
  systemd.services.asusd = {
    after = lib.mkForce [ "graphical.target" ];
    wantedBy = lib.mkForce [ "graphical.target" ];
  };

  # home-manager-gc (718ms on critical path) — garbage collection can wait.
  systemd.services.home-manager-gc = {
    after = lib.mkForce [ "multi-user.target" ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  # ═══════════════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════════════
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
