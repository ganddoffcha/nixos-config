# Profile file, runs on login shells only.
# Most environment variables are now managed by home-manager.
# See /home/gc/home.nix → home.sessionVariables

# Start Hyprland via uwsm (Wayland session manager)
uwsm check may-start && uwsm start hyprland-uwsm.desktop

# Switch escape and caps if tty and no password required
sudo -n loadkeys "$XDG_DATA_HOME/ttymaps.kmap" 2>/dev/null
