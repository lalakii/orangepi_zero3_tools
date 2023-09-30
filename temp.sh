#!/bin/sh
thermals=$(ls -d /sys/class/thermal/thermal_zone*)
cpufreqs=$(find /sys/bus/cpu/devices/cpu*/cpufreq/cpuinfo_cur_freq | sort)
reset
printf "Sensors:\r\n\r\n"
printf "\033[s"
get() {
    value=""
    for t in $thermals; do
        tvalue=$(cat "$t/temp")
        type=$(cat "$t/type")
        tfmt=$(awk -v num="$tvalue" 'BEGIN { printf "%.2f", num / 1000 }')" ℃\n"
        value=$value$type":\t"$tfmt
    done
    printf "\033[u\033[K"
    printf "%s$value"
    printf "\n"
    for u in $cpufreqs; do
        freq=$(($(cat "$u") / 1000))
        parent=$(dirname "$u")
        current=$(dirname "$parent")
        label=$(basename "$current")
        printf "%s%s$label:\t$freq MHz                  \n"
    done
}
while (true); do
    get
    sleep 1
done
######################
#### by lalaki.cn ####
######################
