-- Monstertov - https://tov.monster/
-- monstertov glass: Hyprland (Lua config, Hyprland 0.57+)
-- palette: the blues of tov.monster

local light  = "rgb(65b9f0)"
local deep   = "rgb(0071bc)"
local grey   = "rgba(b4b4b455)"

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "rofi -show drun"
local mainMod     = "SUPER"

---- MONITOR ----
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

---- AUTOSTART ----
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

---- ENV ----
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

---- LOOK ----
hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { light, deep }, angle = 45 },
            inactive_border = grey,
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity   = 0.92,
        inactive_opacity = 0.85,

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,
            vibrancy = 0.18,
            noise    = 0.02,
            popups   = true,
        },

        shadow = {
            enabled        = true,
            range          = 20,
            render_power   = 3,
            color          = "rgba(0071bc33)",
            color_inactive = "rgba(00000055)",
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color = "rgb(141414)",
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
        },
    },
})

---- ANIMATIONS ----
hl.curve("glide", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })
hl.curve("soft",  { type = "bezier", points = { {0.4, 0},  {0.2, 1}  } })
hl.curve("easy",  { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "windowsIn",    enabled = true, speed = 4.1, spring = "easy",  style = "popin 85%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 3,   bezier = "soft",  style = "popin 85%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 4.8, spring = "easy" })
hl.animation({ leaf = "border",       enabled = true, speed = 8,   bezier = "soft" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 60,  bezier = "soft",  style = "loop" })
hl.animation({ leaf = "fade",         enabled = true, speed = 5,   bezier = "soft" })
hl.animation({ leaf = "layers",       enabled = true, speed = 4,   bezier = "glide", style = "fade" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 5,   bezier = "glide", style = "slide" })

---- GESTURES ----
-- three-finger swipe switches workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- three-finger up: fullscreen; four-finger swipe: drag the window under the cursor
hl.gesture({ fingers = 3, direction = "up",    action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "swipe", action = "move" })

---- KEYS ----
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clip | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload; pkill waybar; pkill swaync; waybar & swaync &"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind("Print",                   hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("grim - | wl-copy"))

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- laptop keys
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     held)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   held)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---- RULES ----
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- glass behind the bar, launcher and notifications
hl.layer_rule({
    name  = "glass-layers",
    match = { namespace = "^(waybar|rofi|swaync-control-center|swaync-notification-window)$" },
    blur = true,
    ignore_alpha = 0.2,
})
