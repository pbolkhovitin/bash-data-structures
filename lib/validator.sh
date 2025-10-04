#!/bin/bash

# formatter.sh - Утилиты форматирования вывода для Bash Data Structures

# Форматирование вывода в таблицу
formatter::table() {
    local headers=("$@")
    local data=()
    local column_widths=()
    local IFS=$'\n'
    
    # Читаем данные из stdin
    while read -r line; do
        data+=("$line")
    done
    
    if [[ ${#data[@]} -eq 0 ]]; then
        echo "No data to display"
        return 1
    fi
    
    # Определяем ширину колонок
    for ((i=0; i<${#headers[@]}; i++)); do
        local max_length=${#headers[i]}
        for row in "${data[@]}"; do
            IFS=$'\t' read -ra fields <<< "$row"
            if [[ ${#fields[i]} -gt $max_length ]]; then
                max_length=${#fields[i]}
            fi
        done
        column_widths[i]=$((max_length + 2))
    done
    
    # Вывод заголовков
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "%-${column_widths[i]}s" "${headers[i]}"
    done
    echo
    
    # Разделитель
    for width in "${column_widths[@]}"; do
        printf "%${width}s" | tr ' ' '-'
    done
    echo
    
    # Вывод данных
    for row in "${data[@]}"; do
        IFS=$'\t' read -ra fields <<< "$row"
        for ((i=0; i<${#fields[@]}; i++)); do
            printf "%-${column_widths[i]}s" "${fields[i]}"
        done
        echo
    done
}

# Форматирование в JSON
formatter::json() {
    local type="$1"
    shift
    
    case "$type" in
        "stack")
            local stack_array=("$@")
            local json='{"type": "stack", "data": ['
            for ((i=0; i<${#stack_array[@]}; i++)); do
                if [[ $i -gt 0 ]]; then
                    json+=','
                fi
                local escaped=$(printf '%s' "${stack_array[i]}" | sed 's/"/\\"/g')
                json+="\"$escaped\""
            done
            json+=']}'
            echo "$json"
            ;;
        "queue")
            local queue_array=("$@")
            local json='{"type": "queue", "data": ['
            for ((i=0; i<${#queue_array[@]}; i++)); do
                if [[ $i -gt 0 ]]; then
                    json+=','
                fi
                local escaped=$(printf '%s' "${queue_array[i]}" | sed 's/"/\\"/g')
                json+="\"$escaped\""
            done
            json+=']}'
            echo "$json"
            ;;
        "error")
            local message="$1"
            local code="${2:-1}"
            echo "{\"error\": \"$message\", \"code\": $code}"
            ;;
        "success")
            local message="$1"
            local data="$2"
            if [[ -n "$data" ]]; then
                echo "{\"success\": true, \"message\": \"$message\", \"data\": $data}"
            else
                echo "{\"success\": true, \"message\": \"$message\"}"
            fi
            ;;
        *)
            echo "{\"error\": \"Unknown format type: $type\"}"
            return 1
            ;;
    esac
}

# Форматирование вывода в виде шагов
formatter::steps() {
    local title="$1"
    shift
    local steps=("$@")
    
    echo "📋 $title"
    echo "────────────────────"
    
    for ((i=0; i<${#steps[@]}; i++)); do
        echo "$((i+1)). ${steps[i]}"
    done
    echo
}

# Форматирование прогресс-бара
formatter::progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%" "$percentage"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Цветное форматирование
formatter::color() {
    local color="$1"
    local text="$2"
    
    case "$color" in
        "red") echo -e "\033[0;31m${text}\033[0m" ;;
        "green") echo -e "\033[0;32m${text}\033[0m" ;;
        "yellow") echo -e "\033[1;33m${text}\033[0m" ;;
        "blue") echo -e "\033[0;34m${text}\033[0m" ;;
        "purple") echo -e "\033[0;35m${text}\033[0m" ;;
        "cyan") echo -e "\033[0;36m${text}\033[0m" ;;
        *) echo "$text" ;;
    esac
}

# Экспорт функций
export -f formatter::table formatter::json formatter::steps
export -f formatter::progress formatter::color