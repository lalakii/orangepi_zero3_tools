#!/bin/sh
sr() {
    thermals=$(find /sys/class/thermal/thermal_zone* | sort)
    value=""
    split=","
    len=$(echo "$thermals" | wc -l)
    for t in $thermals; do
        tvalue=$(cat "$t/temp")
        type=$(cat "$t/type")
        tfmt=$(awk -v spl="$split" -v num="$tvalue" 'BEGIN { printf "\"%.2f\"%s",num / 1000, spl}')
        value=$value"\"$type\":"$tfmt
        len=$((len - 1))
        if [ "$len" = "1" ]; then
            split=""
        fi
    done
    sensors=$value
    cpufreqs=$(find /sys/bus/cpu/devices/cpu*/cpufreq/cpuinfo_cur_freq | sort)
    value=""
    len=$(echo "$cpufreqs" | wc -l)
    split=","
    for u in $cpufreqs; do
        freq=$(($(cat "$u") / 1000))
        parent=$(dirname "$u")
        current=$(dirname "$parent")
        label="{\"id\":\""$(basename "$current")
        value="$value$label\",\"freq\":\"$freq\"}$split"
        len=$((len - 1))
        if [ "$len" = "1" ]; then
            split=""
        fi
    done
    core=$value
    mem=$(free | grep -i mem | awk '{print "["$3","$4"]"}')
    cat <<EOF
{
        "sensors":{
                ${sensors}
        },
        "core":[
                ${core}
        ],
        "mem": ${mem}
}
EOF
}

info() {
    eval "$(cat /etc/os-release)"
    host=\"$(hostname)\"
    ip=[\"$(hostname -I | sed "s/ /\",\"/g" | sed 's/,\"*$//')]
    disk=$(df / | tail -n1 | awk '{print "["$3","$4"]"}')
    cat <<EOF
{
    "host":${host},
    "os":"${PRETTY_NAME}",
    "ip":${ip},
    "disk":${disk}
}
EOF
}
case $1 in
"state")
    sr
    ;;
"info")
    info
    ;;
*)
    echo "$0 [ state | info ]"
    ;;
esac

### lalaki.cn ###
