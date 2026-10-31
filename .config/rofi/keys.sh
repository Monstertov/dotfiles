#!/usr/bin/env bash
# Monstertov - https://tov.monster/
# glass shortcut finder: type what you want to do, see what to press.
# package actions at the top actually run (in a kitty window that stays open).

theme='window { width: 780px; } listview { lines: 12; }'
term="kitty --hold -e"

# actionable package commands, shown first. keep the "pkg: " prefix: the case
# block below matches on it to tell an action from a keybind reference row.
actions="$(cat <<'EOF'
pkg: upgrade all (yay -Syu)
pkg: upgrade official only (sudo pacman -Syu)
pkg: install (yay -S)
pkg: install official (sudo pacman -S)
EOF
)"

# keybind cheatsheet, built from hyprland's live binds
binds="$(hyprctl binds -j | jq -r '
    def mods($m): [ [64,"Super"], [4,"Ctrl"], [8,"Alt"], [1,"Shift"] ]
        | map(select(.[0] as $b | $m | (. / $b | floor) % 2 == 1) | .[1]);
    .[] | select(.has_description) | mods(.modmask) as $mods
    | .key |= (
          if . == "slash" then "/"
          elif . == "mouse:272" then "Left Click"
          elif . == "mouse:273" then "Right Click"
          elif . == "mouse:274" then "Middle Click"
          elif . == "mouse_down" then "Scroll Down"
          elif . == "mouse_up" then "Scroll Up"
          elif startswith("XF86") then .[4:]
          else . end)
    | [ .description, (($mods + [.key]) | join(" + ")) ] | @tsv' \
    | sort -u \
    | awk -F'\t' '{ printf "%-34s %s\n", $1, $2 }')"

choice="$(printf '%s\n%s\n' "$actions" "$binds" \
    | rofi -dmenu -i -p "keys" -theme-str "$theme")"

case "$choice" in
    "pkg: upgrade all (yay -Syu)")
        exec $term yay -Syu ;;
    "pkg: upgrade official only (sudo pacman -Syu)")
        exec $term sudo pacman -Syu ;;
    "pkg: install (yay -S)")
        pkg="$(rofi -dmenu -p 'install (yay)' -theme-str "$theme" < /dev/null)" || exit 0
        [ -n "$pkg" ] && exec $term yay -S $pkg ;;
    "pkg: install official (sudo pacman -S)")
        pkg="$(rofi -dmenu -p 'install (pacman)' -theme-str "$theme" < /dev/null)" || exit 0
        [ -n "$pkg" ] && exec $term sudo pacman -S $pkg ;;
esac
