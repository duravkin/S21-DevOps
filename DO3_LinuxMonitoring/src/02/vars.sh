#!/bin/bash

hostname=$(hostname)
timezone=$(timedatectl | grep "Time zone" | sed 's/)//' | awk '{print $3 " UTC " $5/100}')
user=$(whoami)
os=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2 )
date=$(date +"%d %B %Y %T")
uptime=$(uptime -p)
uptime_sec=$(cat /proc/uptime | awk '{print int($1)}')

network=$(ip route show default | awk '{print $5}')
cidr=$(ip addr show $network | grep "inet " | awk '{print $2}' | cut -d'/' -f2)
bit_mask=$(( ( 0xFFFFFFFF << (32 - cidr) ) & 0xFFFFFFFF ))
mask=$(printf "%d.%d.%d.%d\n" \
        $(( (bit_mask >> 24) & 0xFF )) \
        $(( (bit_mask >> 16) & 0xFF )) \
        $(( (bit_mask >> 8) & 0xFF )) \
        $(( bit_mask & 0xFF ))
)

ip=$(ip addr show $network | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
gateway=$(ip route show default | awk '{print $3}')

ram_total=$(free -m | grep Mem | awk '{print $2}')
ram_used=$(free -m | grep Mem | awk '{print $3}')
ram_free=$(free -m | grep Mem | awk '{print $4}')
ram_total_gb=$(echo "scale=3; $ram_total / 1024" | bc | awk '{printf "%.3f\n", $0}')
ram_used_gb=$(echo "scale=3; $ram_used / 1024" | bc | awk '{printf "%.3f\n", $0}')
ram_free_gb=$(echo "scale=3; $ram_free / 1024" | bc | awk '{printf "%.3f\n", $0}')

space_root=$(df -k / | awk 'NR==2 {print $2}')
space_root_used=$(df -k / | awk 'NR==2 {print $3}')
space_root_free=$(df -k / | awk 'NR==2 {print $4}')
space_root_mb=$(echo "scale=2; $space_root / 1024" | bc | awk '{printf "%.2f\n", $0}')
space_root_used_mb=$(echo "scale=2; $space_root_used / 1024" | bc | awk '{printf "%.2f\n", $0}')
space_root_free_mb=$(echo "scale=2; $space_root_free / 1024" | bc | awk '{printf "%.2f\n", $0}')
