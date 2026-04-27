#!/bin/bash

if [ $# -ne 0 ]; then
    echo "Error: The script should run without arguments."
    exit 1
fi

default_column1_background=6
default_column1_font_color=2
default_column2_background=6
default_column2_font_color=3

if [ -f "config.cfg" ]; then
    source config.cfg
fi

column1_background=${column1_background:-$default_column1_background}
column1_font_color=${column1_font_color:-$default_column1_font_color}
column2_background=${column2_background:-$default_column2_background}
column2_font_color=${column2_font_color:-$default_column2_font_color}

bash ../03/main.sh $column1_background $column1_font_color $column2_background $column2_font_color

exit_code=$?
if [ $exit_code -ne 0 ]; then
    exit 1
fi

color_name() {
    case $1 in
        1) echo "white" ;;
        2) echo "red" ;;
        3) echo "green" ;;
        4) echo "blue" ;;
        5) echo "purple" ;;
        6) echo "black" ;;
        *) echo "unknown" ;;
    esac
}

echo
echo "Column 1 background = $( [ "$column1_background" -ne "$default_column1_background" ] && echo "$column1_background ($(color_name $column1_background))" || echo "default ($(color_name $default_column1_background))")"
echo "Column 1 font color = $( [ "$column1_font_color" -ne "$default_column1_font_color" ] && echo "$column1_font_color ($(color_name $column1_font_color))" || echo "default ($(color_name $default_column1_font_color))")"
echo "Column 2 background = $( [ "$column2_background" -ne "$default_column2_background" ] && echo "$column2_background ($(color_name $column2_background))" || echo "default ($(color_name $default_column2_background))")"
echo "Column 2 font color = $( [ "$column2_font_color" -ne "$default_column2_font_color" ] && echo "$column2_font_color ($(color_name $column2_font_color))" || echo "default ($(color_name $default_column2_font_color))")"