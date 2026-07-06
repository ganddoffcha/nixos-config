#!/usr/bin/env bash
# Power profile auto-switcher: toggles eye candy based on AC status.
# Battery → minimal (60Hz, no animations/blur/shadows)
# Charger → full eye candy (240Hz, animations/blur/shadows)
# Managed by home-manager — do not edit directly.

set -euo pipefail

MONITOR="eDP-1"
MODE_BATTERY="2560x1600@60"
MODE_CHARGER="2560x1600@240"
STAMP_FILE="/tmp/auto-refresh-last-state"

# ── Helpers ───────────────────────────────────────────────────────────

ac_online() {
    # Check any Mains-type power supply (ADP0, AC, etc.)
    # More reliable than BAT0/status which reports "Not charging" when
    # the battery is at its charge threshold (e.g. ASUS battery health 80% cap).
    for psu in /sys/class/power_supply/*/; do
        if [[ "$(cat "$psu/type" 2>/dev/null)" == "Mains" ]] && \
           [[ "$(cat "$psu/online" 2>/dev/null)" == "1" ]]; then
            return 0
        fi
    done
    return 1
}

current_refresh_rate() {
    # Extract the first @Hz value from hyprctl monitors (current mode, not availableModes)
    hyprctl monitors 2>/dev/null | grep -oP '@\K[\d.]+' | head -1 | cut -d. -f1
}

apply_battery() {
    hyprctl --batch "\
keyword monitor $MONITOR,${MODE_BATTERY},auto,auto;\
keyword animations:enabled 0;\
keyword decoration:blur:enabled 0;\
keyword decoration:shadow:enabled 0;\
keyword general:gaps_in 0;\
keyword general:border_size 3" >/dev/null 2>&1
}

apply_charger() {
    hyprctl --batch "\
keyword monitor $MONITOR,${MODE_CHARGER},auto,auto;\
keyword animations:enabled 1;\
keyword decoration:blur:enabled 1;\
keyword decoration:shadow:enabled 1;\
keyword general:gaps_in 0;\
keyword general:border_size 3" >/dev/null 2>&1
}

# ── State machine ────────────────────────────────────────────────────

# Determine desired state based on AC
if ac_online; then
    desired="charger"
    expected_hz="240"
else
    desired="battery"
    expected_hz="60"
fi

# Check what Hyprland is actually running (survives Hyprland restarts)
actual_hz=$(current_refresh_rate)

# Apply if the monitor doesn't match the expected refresh rate
if [[ "$actual_hz" != "$expected_hz" ]]; then
    if [[ "$desired" == "charger" ]]; then
        apply_charger
    else
        apply_battery
    fi
fi

echo "$desired" > "$STAMP_FILE"
