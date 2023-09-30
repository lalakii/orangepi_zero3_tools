#!/bin/sh
printf "PID\t\tMEM(KB)\t\tNAME"
for vpath in /proc/*; do
    pid=$(basename "$vpath")
    if [ "$pid" -gt 0 ] 2>/dev/null; then
        grep "Name\|VmRSS" "$vpath"/status | awk -F' ' '{print $2}' | tr "\r\n" "," | awk -va="$pid" -F',' '{if($2)printf "\r\n%s\t\t%s\t\t%s",a,$2,$1}'
    fi
done
printf "\r\n"
################
# by lalaki.cn #
################
