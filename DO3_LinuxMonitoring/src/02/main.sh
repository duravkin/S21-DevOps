#!/bin/bash
source vars.sh

OUTPUT="HOSTNAME = $hostname
TIMEZONE = $timezone
USER = $user
OS = $os
DATE = $date
UPTIME = $uptime
UPTIME_SEC = $uptime_sec
IP = $ip
MASK = $mask
GATEWAY = $gateway
RAM_TOTAL = $ram_total_gb GB
RAM_USED = $ram_used_gb GB
RAM_FREE = $ram_free_gb GB
SPACE_ROOT = $space_root_mb MB
SPACE_ROOT_USED = $space_root_used_mb MB
SPACE_ROOT_FREE = $space_root_free_mb MB
"

echo "$OUTPUT"

read -p "Save data to file? (Y/N): " choice
if [[ $choice =~ ^[Yy]$ ]]; then
    timestamp=$(date +"%d_%m_%y_%H_%M_%S")
    filename="${timestamp}.status"
    echo "$OUTPUT" > "$filename"
    echo "Data saved to $filename"
else
    echo "Data not saved."
fi