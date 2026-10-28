#!/usr/bin/env bash
# Monstertov - https://tov.monster/
# glass shortcut finder: type what you want to do, see what to press

theme='window { width: 780px; } listview { lines: 12; }'

# hyprland modmask bits, in the order you press them
hyprctl binds -j | jq -r '
    def mods($m): [ [64,"Super"], [4,"Ctrl"], [8,"Alt"], [1,"Shift"] ]
        | map(select(.[0] as $b | $m | (. / $b | floor) % 2 == 1) | .[1]);
    .[] | select(.has_description) | mods(.modmask) as $mods
    | .key |= (if . == "slash" then "/" elif startswith("XF86") then .[4:] else . end)
    | [ .description, (($mods + [.key]) | join(" + ")) ] | @tsv' \
    | sort -u \
    | awk -F'\t' '{ printf "%-34s %s\n", $1, $2 }' \
    | rofi -dmenu -i -p "keys" -theme-str "$theme" >/dev/null
