

#!/bin/bash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors!

. ~/.config/statusbar/themes/onedark

cpu() {

	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
 	f=$(cat /sys/class/thermal/thermal_zone0/temp)
    t=$(echo $f | cut -b -2).$(echo $f | cut -b 5-)°C

	printf "^c$black^^b$green^ CPU "
	printf "^c$white^^b$grey^ $cpu_val "
	printf "^c$white^^b$grey^$t"
	
}

# disk() {
# 
	# printf "^c$pink^^b$black^ 󰋊 "
	# printf "$(df -h | awk 'NR==4{print $3,$5}')%"
# 
# }

pkg_updates() {

	updates=$(pacman -Qu | wc -l)
	
	if [ -z "$updates" ]; then
		printf "^b$black^^c$white^󰏕 "
	else
		printf "^b$black^^c$white^󰏕 $updates"
	fi
	
}

mem() {

  printf "^c$white^^b$black^  "
  printf "^c$white^$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"

}

netstat() {
	
	update() {
	    sum=0
	    for arg; do
	        read -r i < "$arg"
	        sum=$(( sum + i ))
	    done
	    cache=${XDG_CACHE_HOME:-$HOME/.cache}/${1##*/}
	    [ -f "$cache" ] && read -r old < "$cache" || old=0
	    printf %d\\n "$sum" > "$cache"
	    printf %d\\n $(( sum - old ))
	}
	
	rx=$(update /sys/class/net/[ew]*/statistics/rx_bytes)
	tx=$(update /sys/class/net/[ew]*/statistics/tx_bytes)
	
	printf "^b$black^^c$white^󰬦 %4sB 󰬬 %4sB\\n" $(numfmt --to=iec $rx) $(numfmt --to=iec $tx)
}

wlan() {

if grep -xq 'up' /sys/class/net/w*/operstate 2>/dev/null ; then
	wifiicon="$(awk '/^\s*w/ { print "󰤥", int($3 * 100 / 70) "% " }' /proc/net/wireless)"
elif grep -xq 'down' /sys/class/net/w*/operstate 2>/dev/null ; then
	grep -xq '0x1003' /sys/class/net/w*/flags && wifiicon="󰤫 " || wifiicon="󰤮 "
fi

printf "%s%s%s\n" "^c$white^^b$black^$wifiicon" "$(sed "s/down/󰈂/;s/up/󰈀/" /sys/class/net/e*/operstate 2>/dev/null)" "$(sed "s/.*//" /sys/class/net/tun*/operstate 2>/dev/null) "

}

clock() {
	printf "^c$black^^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $(date '+%a %d %b %I:%M %p')"
}



volume() {
    # get the current audio level as a percentage
    vol=$(pulsemixer --get-volume | awk '{print $1}')
    mute=$(pulsemixer --get-mute | awk '{print $1}')

    if [ "$mute" = "1" ]; then
        icon="^c$red^"
        echo "$icon ""^c$white^$vol%"
    else
        case 1 in
            $((vol >= 90)) ) icon="^c$red^" ;;
            $((vol >= 30)) ) icon="^c$darkblue^󰕾" ;;
            $((vol >= 1)) ) icon="^c$white^" ;;
            * ) echo 󰸈 && exit ;;
        esac
        echo "$icon ""$vol%"
    fi
}

while true; do

	[ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates) 

	# && weather=$(weathermodule)
	
 interval=$((interval + 1))

	sleep 1 && xsetroot -name "$(volume) $(cpu) $(mem) $(netstat) $(wlan) $(clock) "
done

 
 

