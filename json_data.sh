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
    mem=$(free | grep -i mem | awk '{print "["$3","$2"]"}')
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
    host=$(hostname)
    krv=$(uname -or)
    arch=$(uname -m)
    ip=$(hostname -I | sed "s/ /\",\"/g" | sed 's/,\"*$//')
    disk=$(df / | tail -n1 | awk '{print "["$3","$2"]"}')
    rootfs=$(mount | grep " / " | awk '{print $1}')
    eval "$(blkid | grep "$rootfs" | awk -F ':' '{print $2}')"
    fsck_info=$(tune2fs -l "$rootfs" | grep -i "state\|Mount count" | awk -F':' '{gsub(/[ \t]+/, "", $2); print $2}')
    fs_state=$(echo "$fsck_info" | head -n1 | tail -n1)
    mount_count=$(echo "$fsck_info" | head -n2 | tail -n1)
    mount_max_count=$(echo "$fsck_info" | tail -n1)
    boot_time=$(uptime -s)
    sys_time=$(date +'%Y-%m-%d %H:%M:%S')
    cat <<EOF
{
    "host":"${host}",
    "os":"${PRETTY_NAME}",
    "kernel":"${krv}",
    "machine":"${arch}",
    "ip":["${ip}],
    "disk":${disk},
    "rootfs":"${rootfs}",
    "rootfstype":"${TYPE:-default}",
    "fs_state":"${fs_state}",
    "mount_count":${mount_count},
    "max_count":${mount_max_count},
    "boot_time":"${boot_time}",
    "sys_time":"${sys_time}"
}
EOF
}
all() {
    cat <<EOF
[$(sr),$(info)]
EOF
}
case $1 in
"state")
    sr
    ;;
"info")
    info
    ;;
"all")
    all
    ;;
*)
    echo "$0 [ state | info | all ]"
    ;;
esac
## lalaki.cn ##
