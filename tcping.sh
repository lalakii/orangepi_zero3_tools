#!/bin/sh
url=$1
if [ -z "$url" ]; then
    url="www.163.com"
fi
get() {
    printf "\r\n%s$1\t%s$(curl -ILks "$url" | wc -l | awk '{ if($1 ~ "0")print "Fail";else print "OK" }')"
}
printf "Test: %s$url"
if type curl >/dev/null 2>&1; then
    for num in 1 2 3 4; do
        get $num
    done
else
    printf "\r\ncurl not found\r\n"
fi
printf "\r\n\r\n"
######################
#### by lalaki.cn ####
######################
