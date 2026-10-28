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
        gaps_in  = 3,
        gaps_out = 8,
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

    dwindle = { preserve_split = true, force_split = 2 }, -- new windows always go right or below

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

-- two-finger pinch zooms the focused app: font size in kitty, ctrl +/- everywhere else.
-- hyprland eats the pinch, so browsers get their keyboard zoom instead of smooth zoom.
-- scale is a ratio from 1.0, so steps use log(scale / start) to make in and out symmetric
local pinch_step = math.log(1.15)
local pinch_done = 0
local pinch_base = 1
local function pinch_zoom(e)
    if not e.scale or e.scale <= 0 then return end
    local r = math.log(e.scale / pinch_base) / pinch_step
    local target = r >= 0 and math.floor(r) or -math.floor(-r)
    if target == pinch_done then return end
    local win = hl.get_active_window()
    local mods = (win and win.class == "kitty") and "CTRL SHIFT" or "CTRL"
    local key = target > pinch_done and "equal" or "minus"
    for _ = 1, math.abs(target - pinch_done) do
        hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key }))
    end
    pinch_done = target
end
hl.gesture({
    fingers = 2,
    direction = "pinch",
    action = {
        start = function(e)
            pinch_done = 0
            pinch_base = (e.scale and e.scale > 0) and e.scale or 1
        end,
        update = pinch_zoom,
    },
})

---- KEYS ----
-- every bind gets a desc so Super + / (rofi/keys.sh) can search them
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal),    { desc = "open terminal" })
-- the copilot key sends super + shift + f23; claude is a zsh function, so run it in an interactive zsh
hl.bind(mainMod .. " + SHIFT + F23", hl.dsp.exec_cmd(terminal .. " --directory ~/development zsh -ic 'claude; exec zsh'"), { desc = "open claude code (copilot key)" })
hl.bind(mainMod .. " + Q",         hl.dsp.window.close(),        { desc = "close window" })
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager), { desc = "open file manager" })
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(menu),        { desc = "app launcher" })
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clip | cliphist decode | wl-copy"), { desc = "clipboard history" })
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen(),   { desc = "fullscreen window" })
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }), { desc = "float or tile window" })
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),       { desc = "pseudo tile window" })
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"), { desc = "flip split direction" })
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("loginctl lock-session"), { desc = "lock screen" })
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"),   { desc = "notification panel" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload; pkill waybar; pkill swaync; waybar & swaync &"), { desc = "reload desktop" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit(),                { desc = "log out" })
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("~/.config/rofi/keys.sh"), { desc = "search shortcuts" })
hl.bind("Print",                   hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { desc = "screenshot area to clipboard" })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("grim - | wl-copy"),                  { desc = "screenshot screen to clipboard" })

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,         hl.dsp.focus({ direction = dir }),       { desc = "focus window " .. dir })
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), { desc = "move window " .. dir })
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { desc = "go to workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { desc = "move window to workspace " .. i })
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),            { desc = "show or hide scratchpad" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { desc = "move window to scratchpad" })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "next workspace (scroll)" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { desc = "previous workspace (scroll)" })
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true, desc = "drag window (left mouse)" })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true, desc = "resize window (right mouse)" })

-- laptop keys
local function held(desc) return { locked = true, repeating = true, desc = desc } end
local function locked(desc) return { locked = true, desc = desc } end
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held("volume up"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held("volume down"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     held("mute"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   held("mute microphone"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held("brightness up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held("brightness down"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       locked("next track"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked("play or pause"))
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), locked("play or pause"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   locked("previous track"))

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

-- firefox picture-in-picture: small, on top, bottom right, on every workspace
hl.window_rule({
    name  = "firefox-pip",
    match = { class = "^firefox$", title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    size  = "640 360",
    move  = "monitor_w-660 monitor_h-380",
})

-- glass behind the bar, launcher and notifications
hl.layer_rule({
    name  = "glass-layers",
    match = { namespace = "^(waybar|rofi|swaync-control-center|swaync-notification-window)$" },
    blur = true,
    ignore_alpha = 0.2,
})
