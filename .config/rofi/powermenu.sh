#!/usr/bin/env bash
# Monstertov - https://tov.monster/
# glass power menu: lock, log out, suspend, reboot, power off

lock="󰌾  lock"
logout="󰍃  log out"
suspend="󰒲  suspend"
reboot="󰜉  reboot"
poweroff="󰐥  power off"

choice=$(printf '%s\n' "$lock" "$logout" "$suspend" "$reboot" "$poweroff" \
    | rofi -dmenu -i -p "" -theme-str 'window { width: 300px; } listview { lines: 5; } inputbar { enabled: false; }')

case "$choice" in
    "$lock")     loginctl lock-session ;;
    "$logout")   hyprctl dispatch 'hl.dsp.exit()' ;;
    "$suspend")  systemctl suspend ;;
    "$reboot")   systemctl reboot ;;
    "$poweroff") systemctl poweroff ;;
esac
