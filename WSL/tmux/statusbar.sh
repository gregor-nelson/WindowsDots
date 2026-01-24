#!/bin/bash
# tmux statusbar for WSL dev environment (nerd font icons)
# Pill/badge style matching Android/Termux theme
#
# Palette:
# black=#1e222a  green=#7EC7A2  white=#abb2bf  grey=#282c34
# blue=#61afef   red=#e06c75    orange=#caaa6a  pink=#c678dd
# yellow=#EBCB8B

black="#1e222a"
green="#7EC7A2"
white="#abb2bf"
grey="#282c34"
blue="#61afef"
red="#e06c75"
orange="#caaa6a"
pink="#c678dd"
yellow="#EBCB8B"

# Icons
icon_load="󰍛"
icon_ram="󰧑"
icon_swap="󰾴"
icon_disk="󰋪"
icon_net="󰛳"
icon_uptime="󰅐"
icon_bat_full="󰁹"
icon_bat_90="󰂂"
icon_bat_80="󰂁"
icon_bat_70="󰂀"
icon_bat_60="󰁿"
icon_bat_50="󰁾"
icon_bat_40="󰁽"
icon_bat_30="󰁼"
icon_bat_20="󰁻"
icon_bat_empty="󰂎"

# Load average (1min) - bold green pill (start bookend, like Android CPU)
load_info() {
    local load
    load=$(cut -d' ' -f1 /proc/loadavg)
    local ncpu
    ncpu=$(nproc)
    local color="$white"
    if awk "BEGIN{exit(!($load > $ncpu))}"; then
        color="$red"
    elif awk "BEGIN{exit(!($load > $ncpu * 0.7))}"; then
        color="$yellow"
    fi
    printf "#[fg=%s,bg=%s,bold] %s #[fg=%s,bg=%s,nobold] %s " "$black" "$green" "$icon_load" "$color" "$grey" "$load"
}

# RAM usage
ram_info() {
    local used total pct
    read -r used total <<< "$(free -m | awk '/Mem:/ {print $3, $2}')"
    pct=$((used * 100 / total))
    local color="$white"
    if ((pct > 85)); then
        color="$red"
    elif ((pct > 65)); then
        color="$yellow"
    fi
    local used_g total_g
    used_g=$(awk "BEGIN{printf \"%.1f\", $used/1024}")
    total_g=$(awk "BEGIN{printf \"%.1f\", $total/1024}")
    printf "#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %s#[fg=#5c6370]/#[fg=%s]%sG " "$pink" "$grey" "$icon_ram" "$color" "$grey" "$used_g" "$white" "$total_g"
}

# Swap usage
swap_info() {
    local used total
    read -r used total <<< "$(free -m | awk '/Swap:/ {print $3, $2}')"
    if ((total == 0)); then
        printf "#[fg=%s,bg=%s] %s #[fg=#5c6370,bg=%s] off " "$orange" "$grey" "$icon_swap" "$grey"
        return
    fi
    local pct=$((used * 100 / total))
    local color="$white"
    if ((pct > 50)); then
        color="$red"
    elif ((pct > 25)); then
        color="$yellow"
    fi
    printf "#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %sM#[fg=#5c6370]/#[fg=%s]%sG " "$orange" "$grey" "$icon_swap" "$color" "$grey" "$used" "$white" "$((total/1024))"
}

# Disk space remaining
disk_info() {
    local avail use_pct
    read -r avail use_pct <<< "$(df -h /mnt/c | awk 'NR==2 {print $4, $5}')"
    use_pct=${use_pct%\%}
    local color="$white"
    if ((use_pct > 90)); then
        color="$red"
    elif ((use_pct > 75)); then
        color="$yellow"
    fi
    printf "#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %s%% " "$yellow" "$grey" "$icon_disk" "$color" "$grey" "$use_pct"
}

# WSL IP address
ip_info() {
    local ip
    ip=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
    [[ -z "$ip" ]] && ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    printf "#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %s " "$blue" "$grey" "$icon_net" "$white" "$grey" "$ip"
}

# Battery percentage with dynamic icon
battery_info() {
    local cap_file="/sys/class/power_supply/BAT0/capacity"
    [[ ! -f "$cap_file" ]] && cap_file="/sys/class/power_supply/BAT1/capacity"
    [[ ! -f "$cap_file" ]] && cap_file=$(find /sys/class/power_supply/*/capacity 2>/dev/null | head -1)
    if [[ -f "$cap_file" ]]; then
        local pct
        pct=$(cat "$cap_file")
        local color="$white"
        local icon="$icon_bat_full"
        if ((pct <= 10)); then
            icon="$icon_bat_empty"; color="$red"
        elif ((pct <= 20)); then
            icon="$icon_bat_20"; color="$red"
        elif ((pct <= 30)); then
            icon="$icon_bat_30"; color="$yellow"
        elif ((pct <= 40)); then
            icon="$icon_bat_40"; color="$orange"
        elif ((pct <= 50)); then
            icon="$icon_bat_50"; color="$white"
        elif ((pct <= 60)); then
            icon="$icon_bat_60"; color="$white"
        elif ((pct <= 70)); then
            icon="$icon_bat_70"; color="$white"
        elif ((pct <= 80)); then
            icon="$icon_bat_80"; color="$green"
        elif ((pct <= 90)); then
            icon="$icon_bat_90"; color="$green"
        else
            icon="$icon_bat_full"; color="$green"
        fi
        printf "#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] %s%% " "$color" "$grey" "$icon" "$white" "$grey" "$pct"
    fi
}

# Uptime (compact) - bold blue pill (end bookend, like Android clock)
uptime_info() {
    local up_sec
    up_sec=$(cut -d. -f1 /proc/uptime)
    local days=$((up_sec / 86400))
    local hours=$(( (up_sec % 86400) / 3600 ))
    local mins=$(( (up_sec % 3600) / 60 ))
    local result=""
    ((days > 0)) && result+="${days}d"
    ((hours > 0)) && result+="${hours}h"
    ((days == 0)) && result+="${mins}m"
    printf "#[fg=%s,bg=%s,bold] %s #[fg=%s,bg=%s,nobold] %s " "$black" "$blue" "$icon_uptime" "$black" "$blue" "$result"
}

# Build output
main() {
    local out=""
    out+="$(load_info)"
    out+="$(ram_info)"
    out+="$(swap_info)"
    out+="$(disk_info)"
    out+="$(ip_info)"

    local bat_out
    bat_out=$(battery_info)
    [[ -n "$bat_out" ]] && out+="$bat_out"

    out+="$(uptime_info)"
    out+="#[default]"

    echo "$out"
}

main
