#!/usr/bin/env bash
set -euo pipefail

ROFI_THEME="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
SEPARATOR='|'

rofi_menu() {
    rofi -dmenu -i -p "$1" -theme "$ROFI_THEME"
}

rofi_password() {
    rofi -dmenu -password -p "$1" -theme "$ROFI_THEME"
}

notify() {
    notify-send -h string:x-canonical-private-synchronous:rofi-wifi "$1" "$2" >/dev/null 2>&1 || true
}

wifi_enabled() {
    [ "$(nmcli radio wifi)" = "enabled" ]
}

current_connection() {
    nmcli -t -f NAME,DEVICE,TYPE connection show --active \
        | awk -F: '$3 == "802-11-wireless" { print $1 " (" $2 ")" ; exit }'
}

disconnect_wifi() {
    local device
    device="$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')"
    if [ -n "$device" ]; then
        nmcli device disconnect "$device" >/dev/null
        notify "Wi-Fi" "Disconnected"
    else
        notify "Wi-Fi" "No active Wi-Fi connection"
    fi
}

connect_to_network() {
    local ssid="$1"
    local security="$2"
    local saved pass

    saved="$(nmcli -t -f NAME connection show | awk -v target="$ssid" '$0 == target { print $0; exit }')"
    if [ -n "$saved" ]; then
        if nmcli connection up "$saved" >/dev/null 2>&1; then
            notify "Wi-Fi" "Connected to $ssid"
            exit 0
        fi
    fi

    if [ -n "$security" ] && [ "$security" != "--" ]; then
        pass="$(printf '' | rofi_password "Password for $ssid")"
        [ -z "$pass" ] && exit 0
        if nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
            notify "Wi-Fi" "Connected to $ssid"
        else
            notify "Wi-Fi" "Failed to connect to $ssid"
            exit 1
        fi
    else
        if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
            notify "Wi-Fi" "Connected to $ssid"
        else
            notify "Wi-Fi" "Failed to connect to $ssid"
            exit 1
        fi
    fi
}

menu() {
    local wifi_state current info_line
    wifi_state="Off"
    if wifi_enabled; then
        wifi_state="On"
    fi

    current="$(current_connection || true)"
    if [ -n "$current" ]; then
        info_line="󰖩  Current: $current"
    else
        info_line="󰖪  Current: disconnected"
    fi

    {
        printf '󰖩  Wi-Fi: %s\n' "$wifi_state"
        printf '%s\n' "$info_line"
        printf '󰑐  Rescan\n'
        printf '󰖪  Disconnect\n'
        printf '──────────\n'

        nmcli --colors no --escape no --separator "$SEPARATOR" -t \
            -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes \
            | awk -F"$SEPARATOR" '
                BEGIN { OFS="" }
                {
                    inuse = $1
                    ssid = $2
                    signal = $3
                    security = $4

                    if (ssid == "") next

                    prefix = (inuse == "*") ? "󰖩  " : "󰖪  "
                    secure = (security == "" || security == "--") ? "open" : security
                    print prefix, ssid, " [", signal, "%] {", secure, "}"
                }
            ' | awk '!seen[$0]++'
    } | rofi_menu "Wi-Fi"
}

selection="$(menu || true)"
[ -z "$selection" ] && exit 0

case "$selection" in
    "󰖩  Wi-Fi: On")
        nmcli radio wifi off >/dev/null
        notify "Wi-Fi" "Disabled"
        ;;
    "󰖩  Wi-Fi: Off"|"󰖪  Wi-Fi: Off")
        nmcli radio wifi on >/dev/null
        notify "Wi-Fi" "Enabled"
        ;;
    "󰑐  Rescan")
        nmcli device wifi rescan >/dev/null 2>&1 || true
        notify "Wi-Fi" "Rescanned networks"
        ;;
    "󰖪  Disconnect")
        disconnect_wifi
        ;;
    "󰖩  Current:"*|"󰖪  Current:"*|"──────────")
        exit 0
        ;;
    *)
        ssid="$(printf '%s' "$selection" | sed -E 's/^.[[:space:]]+//' | sed -E 's/[[:space:]]+\[[0-9]+%\][[:space:]]+\{.*\}$//')"
        security="$(printf '%s' "$selection" | sed -nE 's/^.*\{(.*)\}$/\1/p')"
        connect_to_network "$ssid" "$security"
        ;;
esac
