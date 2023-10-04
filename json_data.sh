#!/bin/sh
sr() {
    thermals=$(find /sys/class/thermal/thermal_zone* | sort)
    cpufreqs=$(find /sys/bus/cpu/devices/cpu*/cpufreq/cpuinfo_cur_freq | sort)
    printf "{\n\t\"sensors\":{\n"
    value=""
    split=","
    len=$(echo "$thermals" | wc -l)
    for t in $thermals; do
        tvalue=$(cat "$t/temp")
        type=$(cat "$t/type")
        tfmt=$(awk -v spl="$split" -v num="$tvalue" 'BEGIN { printf "\"%.2f\"%s",num / 1000, spl}')"\n"
        value=$value"\t\t\"$type\":"$tfmt
        len=$((len - 1))
        if [ "$len" = "1" ]; then
            split=""
        fi
    done
    printf "%s$value"
    printf "\t},\n\t\"core\":[\n"
    freqvalue=""
    len=$(echo "$cpufreqs" | wc -l)
    split=","
    for u in $cpufreqs; do
        freq=$(($(cat "$u") / 1000))
        parent=$(dirname "$u")
        current=$(dirname "$parent")
        label="\t\t{\"id\":\""$(basename "$current")
        freqvalue="$freqvalue$label\",\"freq\":\"$freq\"}$split\n"
        len=$((len - 1))

        if [ "$len" = "1" ]; then
            split=""
        fi
    done
    mem="\t\"mem\":"$(free | grep -i mem | awk '{print "["$3","$4"]"}')
    printf "%s$freqvalue\t],\n%s$mem\n}\n\n"
}
info() {
    eval "$(cat /etc/os-release)"
    printf "{\n"
    printf "\t\"host\":\"%s$(hostname)\",\n"
    printf "\t\"os\":\"%s$PRETTY_NAME\",\n"
    printf "\t\"ip\":[\"%s$(hostname -I | sed "s/ /\",\"/g" | sed 's/,\"*$//')],\n"
    printf "\t\"disk\":%s$(df / | tail -n1 | awk '{print "["$3","$4"]"}')"
    printf "\n}\n\n"
}
if [ "$1" = "state" ]; then
    sr
elif [ "$1" = "info" ]; then
    info
else
    echo "$0 [ state | info ]"
fi
