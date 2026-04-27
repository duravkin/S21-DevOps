#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: The script requires exactly one argument."
    exit 1
fi

dir="$1"

if [[ ! "$dir" =~ /$ ]]; then
    echo "Error: Path must end with '/'"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "Error: Directory does not exist or is not accessible."
    exit 1
fi

start_time=$(date +%s.%3N)

total_folders=$(find "$dir" -type d 2>/dev/null | wc -l)

top_5_folders=$(du -h "$dir" --max-depth=1 2>/dev/null | sort -hr | head -n 6 | awk 'NR==1 {next} {print NR-1 " - " $2 "/, " $1}')

total_files=$(find "$dir" -type f 2>/dev/null | wc -l)

config_files=$(find "$dir" -type f -name "*.conf" 2>/dev/null | wc -l)
text_files=0
exec_files=$(find "$dir" -type f -executable 2>/dev/null | wc -l)
log_files=$(find "$dir" -type f -name "*.log" 2>/dev/null | wc -l)
archives=0
symlinks=$(find "$dir" -type l 2>/dev/null | wc -l)

while IFS= read -r file; do
    if file "$file" | grep -q "ASCII text"; then
        ((text_files++))
    elif file "$file" | grep -Eiq "gzip|bzip2|zip|rar|xz"; then
        ((archives++))
    fi
done < <(find "$dir" -type f 2>/dev/null)

top_10_files=$(find "$dir" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 10 | awk '{print NR " - " $2 ", " $1 ", " substr($2, index($2,".")+1)}')

top_10_executables=$(find "$dir" -type f -executable -exec du -h {} + 2>/dev/null | sort -hr | head -n 10 | awk '{cmd="md5sum \""$2"\""; cmd | getline hash; close(cmd); print NR " - " $2 ", " $1 ", " hash}')

end_time=$(date +%s.%3N)
execution_time=$(echo "$end_time - $start_time" | bc)

echo "Total number of folders (including all nested ones) = $total_folders"
echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
echo "$top_5_folders"
echo "Total number of files = $total_files"
echo "Number of:"
echo "Configuration files (with the .conf extension) = $config_files"
echo "Text files = $text_files"
echo "Executable files = $exec_files"
echo "Log files (with the extension .log) = $log_files"
echo "Archive files = $archives"
echo "Symbolic links = $symlinks"
echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
echo "$top_10_files"
echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
echo "$top_10_executables"
echo "Script execution time (in seconds) = $(printf "%.1f" "$execution_time")"