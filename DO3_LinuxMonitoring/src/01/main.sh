#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: The script requires exactly one argument."
    exit 1
fi

if [[ $1 =~ ^-?([0-9]*\.)?[0-9]+$ ]]; then
    echo "Invalid input: parameter is a number"
    exit 1
else
    echo "$1"
fi