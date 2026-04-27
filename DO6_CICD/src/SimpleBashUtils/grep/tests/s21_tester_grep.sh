#!/bin/bash

# Определяем переменные для флагов
FLAGS=("i" "v" "c" "l" "n" "h" "s" "o")
SPECIAL_FLAGS=("e" "f")

# Директория с тестовыми файлами
DATA_DIR="data-samples"

# Счетчики успешных и неуспешных тестов
success_count=0
failure_count=0

# Программа для тестирования
S21_GREP="../s21_grep"
GREP="grep"

# Сборка проекта
cd ..
make
cd tests

# Проверка, существует ли директория
if [ ! -d "$DATA_DIR" ]; then
    echo "Директория $DATA_DIR не найдена."
    exit 1
fi

# Цвета для вывода
GREEN='\033[0;32m'  # Зеленый
RED='\033[0;31m'    # Красный
NC='\033[0m'        # Сброс цвета

# Определяем массив команд для вызова grep
simple_commands=(
    "'test' test1.txt"
    "'Grep' test2.txt"
    "-i 'hello' test3.txt"
    "-n 'test' test2.txt"
    "-v 'test' test1.txt"
    "-c 'test' test2.txt"
    "-o 'powerful' test1.txt"
    "-E 'test|powerful' test1.txt"
    "'test' test1.txt test2.txt"
    "'test' nonexistent_file.txt"
)

# Основной цикл по всем текстовым файлам
for file in "$DATA_DIR"/*; do
    # Проверка, существует ли файл
    if [ -f "$file" ]; then
        echo "========================================"
        echo -e "${GREEN}Обработка файла: $file${NC}"
        echo "========================================"
        
            # Цикл по всем флагам
            for flag in "${FLAGS[@]}"; do
                trimmed_flag="-${flag}"

                # Запуск программ и перенаправление потока вывода в файлы
                $GREP $trimmed_flag -f "data-samples/patterns.txt" "$file" > output_grep.temp
                $S21_GREP $trimmed_flag -f "data-samples/patterns.txt" "$file" > output_s21_grep.temp

                # Сравнение выводов
                if diff -q output_grep.temp output_s21_grep.temp > /dev/null; then
                    echo "✅ Выводы совпадают для флага: ${trimmed_flag}"
                    ((success_count++))  # Увеличиваем счетчик успешных выводов
                else
                    echo
                    echo "❌ Выводы не совпадают для флага: ${trimmed_flag}"
                    echo -e "--- Ожидаемый вывод (grep) ---${GREEN}"
                    cat output_grep.temp
                    echo -e "${NC}"
                    echo -e "--- Полученный вывод (s21_grep) ---${RED}"
                    cat output_s21_grep.temp
                    echo -e "${NC}"
                    ((failure_count++))  # Увеличиваем счетчик неуспешных выводов
                fi
            done
       
    else
        echo "Нет текстовых файлов в директории $DATA_DIR."
    fi
done

# Удаление временных файлов
rm output_grep.temp output_s21_grep.temp

# Вывод итогов
echo "========================================"
echo "Итоги тестирования:"
echo "✅ Успешно пройдено: $success_count"
echo "❌ Неуспешно: $failure_count"
echo "========================================"

if [ $failure_count -ne 0 ]; then
    echo "В ходе тестирования обнаружены ошибки!"
    exit 1
fi