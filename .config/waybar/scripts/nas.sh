#!/usr/bin/env bash
# waybar module: show and toggle the NAS NFS mount
# usage: nas.sh status | toggle
set -u

NAS_SOURCE="${NAS_SOURCE:-monsternas:/volume1/Cloud}"
NAS_MOUNT="${NAS_MOUNT:-/mnt/cloud}"
NAS_OPTS="${NAS_OPTS:-vers=3,soft,timeo=50}"
SIGNAL=9

status() {
    if mountpoint -q "$NAS_MOUNT"; then
        printf '{"text":"󰣳","class":"mounted","tooltip":"NAS mounted at %s\\nclick to unmount"}\n' "$NAS_MOUNT"
    else
        printf '{"text":"󰣳","class":"unmounted","tooltip":"NAS not mounted\\nclick to mount %s"}\n' "$NAS_MOUNT"
    fi
}

toggle() {
    local err
    if mountpoint -q "$NAS_MOUNT"; then
        err=$(sudo -n umount "$NAS_MOUNT" 2>&1) || notify-send -u critical "NAS" "unmount failed: $err"
    else
        err=$(timeout 15 sudo -n mount -t nfs -o "$NAS_OPTS" "$NAS_SOURCE" "$NAS_MOUNT" 2>&1) \
            || notify-send -u critical "NAS" "mount failed: ${err:-timed out}"
    fi
    pkill -RTMIN+"$SIGNAL" waybar
}

case "${1:-status}" in
    status) status ;;
    toggle) toggle ;;
    *) echo "usage: $0 status|toggle" >&2; exit 2 ;;
esac
