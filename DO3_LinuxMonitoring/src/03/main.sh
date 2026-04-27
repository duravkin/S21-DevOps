#!/bin/bash
source ../02/vars.sh

if [ $# -ne 4 ]; then
    echo "Error: The script requires exactly 4 arguments (1-6)."
    exit 1
fi

for arg in "$@"; do
    if ! [[ $arg =~ ^[1-6]$ ]]; then
        echo "Error: Arguments must be numbers from 1 to 6."
        exit 1
    fi
done

if [ "${1}" == "${2}" ] || [ "${3}" == "${4}" ]; then
    echo "Error: Background and text color for a column must not match."
    exit 1
fi

declare -A text_colors=(
    [1]="37"  # white
    [2]="31"  # red
    [3]="32"  # green
    [4]="34"  # blue
    [5]="35"  # purple
    [6]="30"  # black
)

declare -A bg_colors=(
    [1]="47"  # white
    [2]="41"  # red
    [3]="42"  # green
    [4]="44"  # blue
    [5]="45"  # purple
    [6]="40"  # black
)

reset="\e[0m"
bg1="\e[${bg_colors[$1]}m"
fg1="\e[${text_colors[$2]}m"
bg2="\e[${bg_colors[$3]}m"
fg2="\e[${text_colors[$4]}m"

echo -e "${bg1}${fg1}HOSTNAME = ${reset}${bg2}${fg2}$hostname${reset}"
echo -e "${bg1}${fg1}TIMEZONE = ${reset}${bg2}${fg2}$timezone${reset}"
echo -e "${bg1}${fg1}USER = ${reset}${bg2}${fg2}$user${reset}"
echo -e "${bg1}${fg1}OS = ${reset}${bg2}${fg2}$os${reset}"
echo -e "${bg1}${fg1}DATE = ${reset}${bg2}${fg2}$date${reset}"
echo -e "${bg1}${fg1}UPTIME = ${reset}${bg2}${fg2}$uptime${reset}"
echo -e "${bg1}${fg1}UPTIME_SEC = ${reset}${bg2}${fg2}$uptime_sec${reset}"
echo -e "${bg1}${fg1}IP = ${reset}${bg2}${fg2}$ip${reset}"
echo -e "${bg1}${fg1}MASK = ${reset}${bg2}${fg2}$mask${reset}"
echo -e "${bg1}${fg1}GATEWAY = ${reset}${bg2}${fg2}$gateway${reset}"
echo -e "${bg1}${fg1}RAM_TOTAL = ${reset}${bg2}${fg2}$ram_total_gb GB${reset}"
echo -e "${bg1}${fg1}RAM_USED = ${reset}${bg2}${fg2}$ram_used_gb GB${reset}"
echo -e "${bg1}${fg1}RAM_FREE = ${reset}${bg2}${fg2}$ram_free_gb GB${reset}"
echo -e "${bg1}${fg1}SPACE_ROOT = ${reset}${bg2}${fg2}$space_root_mb MB${reset}"
echo -e "${bg1}${fg1}SPACE_ROOT_USED = ${reset}${bg2}${fg2}$space_root_used_mb MB${reset}"
echo -e "${bg1}${fg1}SPACE_ROOT_FREE = ${reset}${bg2}${fg2}$space_root_free_mb MB${reset}"