#!/bin/bash

# Директория с материалами для теста
DATA_DIR="data-samples"

# Перейдём в директорию с материалами для теста
if [ ! -d "$DATA_DIR" ]; then
    mkdir $DATA_DIR
fi
cd $DATA_DIR

# Имя файла, в который будут записаны символы ASCII
output_file="GEN_ascii_characters.txt"

# Создаем или очищаем файл
> "$output_file"

# Цикл для генерации символов ASCII
for i in {0..127}; do
    # Записываем символ в файл
    printf "| DEC: %d - CHAR: %b |\n" "$i" "$(printf "\\$(printf '%03o' "$i")")" >> "$output_file"
done

echo "Файл '$output_file' успешно создан с символами ASCII."

#########################################

# Имя файла, который будет заполнен случайными символами
output_file="GEN_random_characters.txt"

# Количество случайных символов, которые нужно сгенерировать
num_chars=1000  # Вы можете изменить это значение по своему усмотрению

# Создаем или очищаем файл
> "$output_file"

# Генерируем случайные символы и записываем их в файл
for ((i = 0; i < num_chars; i++)); do
    # Генерируем случайный символ из диапазона ASCII (0-127)
    random_char=$(printf "\\$(printf '%03o' $((RANDOM % 128)))")
    echo -n "$random_char" >> "$output_file"
done

echo -e "\nФайл '$output_file' успешно создан и заполнен случайными символами."

#########################################
# Создание прочих файлов для тестирования
#########################################

echo "This is a simple text file." > text_file.txt

cat <<EOL > multi_line_file.txt
This is the first line.
This is the second line.
This is the third line.
EOL

echo -e "This line has spaces   and tabs\t\t\tat the end." > spaces_tabs_file.txt

echo -e "Line 1\nLine 2\tLine 3" > invisible_chars_file.txt

for i in {0..127}; do printf "\\$(printf '%03o' $i)" >> ascii_file.txt; done

touch empty_file.txt

printf "This is a very long line that continues and continues to check how the program handles long lines.\n" > long_line_file.txt

cat <<EOL > html_file.html
<html>
<head><title>HTML Example</title></head>
<body><h1>Hello, world!</h1></body>
</html>
EOL

echo '{"name": "Ivan", "age": 30, "city": "Moscow"}' > json_file.json

echo -e "Name,Age,City\nIvan,30,Moscow\nMaria,25,St. Petersburg" > data.csv

cat <<EOL > markdown_file.md
# Level 1 Header
## Level 2 Header
This is *italic* and **bold text**.
EOL

echo -e "This line has characters: \a \b \c \d" > control_chars_file.txt

echo -n -e "\x00\x01\x02\x03\x04\x05" > binary_data_file.bin

# Чисто по приколу
python3 -c "import sys; sys.set_int_max_str_digits(0); import math; open('factorial_result.txt', 'w').write(str(math.factorial(1000000)))"

# Цвета для вывода
GREEN='\033[0;32m'  # Зеленый
RED='\033[0;31m'    # Красный
NC='\033[0m'        # Сброс цвета

echo -e "${GREEN}Все файлы для тестирования успешно созданы!${NC}"
echo