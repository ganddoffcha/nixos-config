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
  # STEAM — gaming platform, enables 32-bit support + controller udev rules
  # Proton-GE for better game compatibility (media codecs, FSR, game-specific fixes)
  # ═══════════════════════════════════════════════════════════════════════
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # ═══════════════════════════════════════════════════════════════════════
  # GAMESCOPE — micro-compositor for gaming on Wayland (frame pacing, FSR, HDR)
  # ═══════════════════════════════════════════════════════════════════════
  programs.gamescope.enable = true;

  # ═══════════════════════════════════════════════════════════════════════
  # ASUS DAEMON — charge limits, fan curves, platform profiles
  # ═══════════════════════════════════════════════════════════════════════
  services.asusd = {
    enable = true;
  };

  # Override asusd balanced profile EPP from BalancePower → BalancePerformance.
  # asusd sets EPP based on platform_profile and was overriding our
  # balance_performance setting with BalancePower, keeping CPU in low-power
  # frequency mode even on AC. BalancePerformance lets the CPU clock up
  # when needed while still saving power at idle.
  environment.etc."asusd/asusd.ron" = {
    mode = "0444";
    text = ''
      (
          charge_control_end_threshold: 80,
          base_charge_control_end_threshold: 80,
          disable_nvidia_powerd_on_battery: true,
          ac_command: "",
          bat_command: "",
          platform_profile_linked_epp: true,
          platform_profile_on_battery: Quiet,
          change_platform_profile_on_battery: true,
          platform_profile_on_ac: Performance,
          change_platform_profile_on_ac: true,
          profile_quiet_epp: Power,
          profile_balanced_epp: BalancePerformance,
          profile_custom_epp: Performance,
          profile_performance_epp: Performance,
          ac_profile_tunings: {},
          dc_profile_tunings: {
              Quiet: (
                  enabled: false,
                  group: {},
              ),
          },
          armoury_settings: {},
      )
    '';
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
  # POWER ADAPTER HOTPLUG — PCIe ASPM, CPU power limits, EPP, platform profile
  # ═══════════════════════════════════════════════════════════════════════
  services.udev.extraRules = let
    thermal-script = pkgs.writeShellScript "thermal-hotplug" ''
      set -eu
      RAPL="/sys/devices/virtual/powercap/intel-rapl/intel-rapl:0"

      # ── Detect AC ─────────────────────────────────────────────────────
      # Ground truth: Mains-type online flags OR battery EC status.
      # ADP0's online flag can be stuck at 0 on this ASUS (hibernate/resume
      # EC quirk) while the battery EC reports "Charging" — so the battery
      # status must be included as a fallback signal.
      on_ac=0
      for psu in /sys/class/power_supply/*/; do
        t="$(cat "$psu/type" 2>/dev/null || true)"
        if [ "$t" = "Mains" ] && [ "$(cat "$psu/online" 2>/dev/null)" = "1" ]; then
          on_ac=1
        elif [ "$t" = "Battery" ]; then
          st="$(cat "$psu/status" 2>/dev/null || true)"
          [ "$st" = "Charging" ] || [ "$st" = "Full" ] && on_ac=1
        fi
      done

      if [ "$on_ac" = "1" ]; then
        echo performance       > /sys/module/pcie_aspm/parameters/policy
        echo 45000000          > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 115000000         > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo balanced          > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo balance_performance > "$c" || true
        done
      else
        echo powersupersave    > /sys/module/pcie_aspm/parameters/policy
        echo 20000000          > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 35000000          > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo quiet             > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo power > "$c" || true
        done
      fi

      touch /tmp/power-supply-event
      chown gc:users /tmp/power-supply-event
    '';
  in ''
    # Power source change (plug/unplug, battery status change) → re-apply
    # thermal policy. Script self-detects AC — do NOT trust POWER_SUPPLY_ONLINE
    # (ADP0 online can be stuck at 0 on this ASUS).
    SUBSYSTEM=="power_supply", ATTR{status}=="?*", RUN+="${thermal-script}"
    SUBSYSTEM=="power_supply", ATTR{online}=="?*", RUN+="${thermal-script}"
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
  # CPU THERMAL MANAGEMENT — cap RAPL power limits + tune EPP
  #
  # i7-13620H (45W base / 115W max turbo). ASUS firmware sets PL1=200W
  # in performance mode which the laptop chassis cannot cool, causing
  # constant PROCHOT thermal throttling (125K+ events logged).
  #
  # KEY FINDING (2026-07-28): RAPL sysfs constraint_0_max_power_uw = 45W.
  # Writes above 45W are silently rejected by the kernel driver. The 80W
  # PL1 cap never worked — it was ignored. 45W is the hardware-enforced
  # sysfs maximum and matches the i7-13620H base TDP.
  #
  # Fix: PL1=45W (was 80W, silently rejected), PL2=115W, governor=performance
  # on AC, EPP=balance_performance. asusd balanced profile EPP changed to
  # BalancePerformance (was BalancePower) via environment.etc override below.
  # ═══════════════════════════════════════════════════════════════════════

  # Boot-time: set RAPL caps + governor + EPP based on AC status (before login)
  systemd.services.cpu-thermal-mgmt = {
    description = "Cap CPU power limits, set governor and EPP based on AC status";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      RAPL="/sys/devices/virtual/powercap/intel-rapl/intel-rapl:0"

      # Check if on AC power
      on_ac=0
      for psu in /sys/class/power_supply/*/type; do
        if [ "$(cat "$psu" 2>/dev/null)" = "Mains" ]; then
          online="$(echo "$psu" | sed 's|/type||')/online"
          if [ "$(cat "$online" 2>/dev/null)" = "1" ]; then
            on_ac=1; break
          fi
        fi
      done

      if [ "$on_ac" = "1" ]; then
        # AC: gaming-ready — PL1=45W (RAPL sysfs max), PL2=115W, performance governor
        echo 45000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 115000000 > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo balanced  > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo performance > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo balance_performance > "$c" || true
        done
      else
        # Battery: max life — PL1=20W, quiet profile, powersave governor
        echo 20000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 35000000  > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo quiet     > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo powersave > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo power > "$c" || true
        done
      fi
    '';
  };

  # Post-login: re-apply RAPL caps + governor + EPP (after asusd + graphical)
  # asusd sets platform_profile_on_ac=Performance which triggers firmware
  # PL1=200W MSR write. This service runs AFTER asusd to override PL1 back.
  systemd.services.cpu-thermal-profile = {
    description = "Re-apply CPU thermal caps after asusd starts";
    after = [ "asusd.service" "graphical.target" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      RAPL="/sys/devices/virtual/powercap/intel-rapl/intel-rapl:0"

      on_ac=0
      for psu in /sys/class/power_supply/*/type; do
        if [ "$(cat "$psu" 2>/dev/null)" = "Mains" ]; then
          online="$(echo "$psu" | sed 's|/type||')/online"
          if [ "$(cat "$online" 2>/dev/null)" = "1" ]; then
            on_ac=1; break
          fi
        fi
      done

      if [ "$on_ac" = "1" ]; then
        # Re-cap PL1 after asusd may have triggered firmware 200W override
        echo 45000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 115000000 > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo balanced  > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo performance > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo balance_performance > "$c" || true
        done
      else
        echo 20000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 35000000  > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo quiet     > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo powersave > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo power > "$c" || true
        done
      fi
    '';
  };

  # Re-apply thermal caps on resume from suspend/hibernate
  systemd.services.cpu-thermal-mgmt-resume = {
    description = "Re-apply CPU thermal caps after resume";
    after = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      RAPL="/sys/devices/virtual/powercap/intel-rapl/intel-rapl:0"

      on_ac=0
      for psu in /sys/class/power_supply/*/type; do
        if [ "$(cat "$psu" 2>/dev/null)" = "Mains" ]; then
          online="$(echo "$psu" | sed 's|/type||')/online"
          if [ "$(cat "$online" 2>/dev/null)" = "1" ]; then
            on_ac=1; break
          fi
        fi
      done

      if [ "$on_ac" = "1" ]; then
        echo 45000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 115000000 > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo balanced  > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo performance > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo balance_performance > "$c" || true
        done
      else
        echo 20000000  > "$RAPL/constraint_0_power_limit_uw" 2>/dev/null || true
        echo 35000000  > "$RAPL/constraint_1_power_limit_uw" 2>/dev/null || true
        echo quiet     > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          [ -f "$c" ] && echo powersave > "$c" || true
        done
        for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          [ -f "$c" ] && echo power > "$c" || true
        done
      fi
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════════════
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
