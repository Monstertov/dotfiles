#!/usr/bin/env bash
# Monstertov - https://tov.monster/
# glass wi-fi menu: pick a network, toggle wi-fi, or open the full editor

theme='window { width: 420px; } listview { lines: 10; }'

if [[ "$(nmcli -t -f WIFI radio)" == "enabled" ]]; then
    toggle="󰖪  turn wi-fi off"
else
    toggle="󰖩  turn wi-fi on"
fi
editor="󰒓  edit connections"

# one line per network: in-use mark, signal bars, lock, ssid
lock_icon=$'\uf023'
list=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan auto 2>/dev/null \
    | awk -F: -v L="$lock_icon" '$4 != "" && !seen[$4]++ {
        bars = ($2 >= 75) ? "󰤨" : ($2 >= 50) ? "󰤥" : ($2 >= 25) ? "󰤢" : "󰤟"
        lock = ($3 == "" || $3 == "--") ? "  " : L " "
        mark = ($1 == "*") ? "  ● " : "    "
        print bars mark lock $4
    }')

choice=$(printf '%s\n%s\n%s\n' "$toggle" "$editor" "$list" | sed '/^$/d' \
    | rofi -dmenu -i -p "󰖩" -theme-str "$theme")
[[ -z "$choice" ]] && exit 0

case "$choice" in
    "$toggle")
        [[ "$toggle" == *off ]] && nmcli radio wifi off || nmcli radio wifi on
        exit 0 ;;
    "$editor")
        nm-connection-editor & exit 0 ;;
esac

# strip the icon columns to get the ssid back
ssid=$(sed -E 's/^.{1}( {4}|  ● )..//' <<< "$choice")

# known network: just bring it up; new one: ask for the password if it has a lock
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" && notify-send "wi-fi" "connected to $ssid"
    exit 0
fi

security=$(nmcli -t -f SSID,SECURITY device wifi list 2>/dev/null | awk -F: -v s="$ssid" '$1 == s { print $2; exit }')
if [[ -n "$security" && "$security" != "--" ]]; then
    pass=$(rofi -dmenu -password -p "password" -theme-str 'window { width: 420px; } listview { enabled: false; }' </dev/null)
    [[ -z "$pass" ]] && exit 0
    nmcli device wifi connect "$ssid" password "$pass" \
        && notify-send "wi-fi" "connected to $ssid" \
        || notify-send "wi-fi" "could not connect to $ssid"
else
    nmcli device wifi connect "$ssid" \
        && notify-send "wi-fi" "connected to $ssid" \
        || notify-send "wi-fi" "could not connect to $ssid"
fi
