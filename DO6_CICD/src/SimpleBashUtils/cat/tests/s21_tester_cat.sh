#!/bin/bash

# Определяем переменные для разных операционных систем
if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS
    FLAGS=(" " "-n" "-b" "-s" "-e" "-t" "-v")
else
    # Linux
    FLAGS=(" " "-n" "-b" "-s" "-E" "-T" "-e" "-t" "-v")
fi

# Запуск скрипта с генерацией файлов для теста
bash ./_generate.sh

# Директория с тестовыми файлами
DATA_DIR="data-samples"

# Счетчики успешных и неуспешных тестов
success_count=0
failure_count=0

# Программа для тестирования
S21_CAT="../s21_cat"
CAT="cat"

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

# Основной цикл по всем текстовым файлам
for file in "$DATA_DIR"/*; do
    # Проверка, существует ли файл
    if [ -f "$file" ]; then
        echo "========================================"
        echo -e "${GREEN}Обработка файла: $file${NC}"
        echo "========================================"
        # Цикл по всем флагам
        for flag in "${FLAGS[@]}"; do
            # Запуск программ и перенаправление потока вывода в файлы
            $CAT $flag "$file" > output_cat.temp
            $S21_CAT $flag "$file" > output_s21_cat.temp

            # Сравнение выводов
            if diff -q output_cat.temp output_s21_cat.temp > /dev/null; then
                echo "✅ Выводы совпадают для флага: ${flag}"
                ((success_count++))  # Увеличиваем счетчик успешных выводов
            else
                echo
                echo "❌ Выводы не совпадают для флага: ${flag}"
                echo -e "--- Ожидаемый вывод (cat) ---${GREEN}"
                cat output_cat.temp
                echo -e "${NC}"
                echo -e "--- Полученный вывод (s21_cat) ---${RED}"
                cat output_s21_cat.temp
                echo -e "${NC}"
                ((failure_count++))  # Увеличиваем счетчик неуспешных выводов
            fi
        done
    else
        echo "Нет текстовых файлов в директории $DATA_DIR."
    fi
done

# Удаление временных файлов
rm output_cat.temp output_s21_cat.temp

# Вывод итогов
echo "========================================"
echo "Итоги тестирования:"
echo "✅ Успешно пройдено: $success_count"
echo "❌ Неуспешно: $failure_count"
echo "========================================"

# Удаление временных файлов для тестов
rm -rf "$DATA_DIR"

if [ $failure_count -ne 0 ]; then
    echo "В ходе тестирования обнаружены ошибки!"
    exit 1
fi