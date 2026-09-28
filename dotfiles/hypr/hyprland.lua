-- Hyprland Lua config (migrated from hyprland.conf)
-- Hyprland 0.56+ prefers this format; the legacy .conf format is deprecated
-- and will be removed in a future update.
-- https://wiki.hypr.land/Configuring/Start/

-----------------
---- MONITORS ----
-----------------
hl.monitor({ output = "eDP-1",    mode = "2560x1600@240", position = "0x0",       scale = "1.6" })
-- hl.monitor({ output = "eDP-1",    mode = "highrr",        position = "auto",      scale = "3.2" })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@119.80", position = "auto-up", scale = "2" })
hl.monitor({ output = "HDMI-A-1", mode = "preferred",     position = "auto-right", scale = "1" })
-- hl.monitor({ output = "DP-3",     mode = "highres",       position = "auto-up",   scale = "1" })

-- unscale XWayland
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


------------------
---- MY PROGRAMS ----
------------------
local terminal    = "kitty"
local fileManager = terminal .. " -e yazi"
local menu        = "~/scripts/bemenu-run"


----------------
---- AUTOSTART ----
----------------
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
    hl.exec_cmd('[ -f ~/.config/catppuccin/current-accent-hex ] && hyprctl keyword general:col.active_border "rgba($(cat ~/.config/catppuccin/current-accent-hex)ff)"')
end)


----------------------------
---- ENVIRONMENT VARIABLES ----
----------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


--------------------
---- LOOK AND FEEL ----
--------------------
-- NOTE: These are charger-level defaults ("rice mode").
-- auto-refresh.sh strips everything to minimal on battery
-- (rounding 0, gaps 0, no blur/shadows/animations).
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 3,

        col = {
            active_border   = "rgba(89b4faff)",
            inactive_border = "rgba(6c7086ff)",
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        layout = "master",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            -- Catppuccin Mocha: base
            color        = "rgba(1e1e2eee)",
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,

            vibrancy = 0.2,
        },
    },
})

hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.config({
    master = {
        new_status = "master",
        mfact      = 0.5,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
        enable_swallow          = true,
    },
})


-------------
---- INPUT ----
-------------
hl.config({
    input = {
        kb_layout = "us",
        repeat_delay = 300,
        repeat_rate  = 50,

        follow_mouse = 2,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll       = true,
            scroll_factor        = 0.1,
            disable_while_typing = true,
        },
    },
})

hl.config({
    cursor = {
        no_hardware_cursors = false,
        zoom_rigid          = true,
        -- zoom_detached_camera (default true since Hyprland 0.56) locks the
        -- zoomed camera at the anchor.  false restores the pre-0.56 behaviour:
        -- with zoom_rigid, the view tracks the cursor (anchor kept centred).
        zoom_detached_camera = false,
        inactive_timeout     = 1,
    },
})

hl.device({
    name        = "asus-rog-strix-impact",
    sensitivity = -1,
})


------------------
---- KEYBINDINGS ----
------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- " .. fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("uwsm app -- " .. menu))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + Z",        hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1 & hyprctl setcursor Bibata-Modern-Classic 24"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 10 & hyprctl setcursor inviscursor-theme 24"))

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd('uwsm app -- grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -an"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"))
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"))
hl.bind("XF86KbdBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +33%"))
hl.bind("XF86KbdBrightnessDown",hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 33%-"))

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("toggle_touchpad"))

-- Writable user bindings (add custom keybinds here without rebuild)
local bindingsPath = os.getenv("HOME") .. "/.config/hypr/bindings.lua"
local bindingsFile = io.open(bindingsPath, "r")
if bindingsFile then
    bindingsFile:close()
    dofile(bindingsPath)
end
