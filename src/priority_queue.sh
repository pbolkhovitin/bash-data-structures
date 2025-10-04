#!/bin/bash

# priority_queue.sh - Реализация приоритетной очереди на Bash
# Элементы с высшим приоритетом извлекаются первыми

source ../lib/logger.sh
source ../lib/validator.sh

# Глобальные переменные
declare -a priority_queue=()
declare -a priorities=()

# Инициализация приоритетной очереди
init_priority_queue() {
    priority_queue=()
    priorities=()
    log "INFO" "Приоритетная очередь инициализирована"
}

# Добавление элемента с приоритетом
priority_enqueue() {
    local element="$1"
    local priority="$2"
    
    if ! validate_element "$element"; then return 1; fi
    
    if ! [[ "$priority" =~ ^[0-9]+$ ]]; then
        log "ERROR" "Приоритет должен быть числом: $priority"
        return 1
    fi
    
    # Вставляем элемент в правильную позицию согласно приоритету
    local i=0
    while [[ $i -lt ${#priorities[@]} && ${priorities[$i]} -gt $priority ]]; do
        ((i++))
    done
    
    # Вставляем элемент на найденную позицию
    priority_queue=("${priority_queue[@]:0:$i}" "$element" "${priority_queue[@]:$i}")
    priorities=("${priorities[@]:0:$i}" "$priority" "${priorities[@]:$i}")
    
    log "DEBUG" "PRIORITY_ENQUEUE: '$element' с приоритетом $priority (размер: ${#priority_queue[@]})"
    echo "$element"
}

# Извлечение элемента с высшим приоритетом
priority_dequeue() {
    if [[ ${#priority_queue[@]} -eq 0 ]]; then
        echo "Ошибка: приоритетная очередь пуста" >&2
        return 1
    fi
    
    local element="${priority_queue[0]}"
    local priority="${priorities[0]}"
    
    # Удаляем первый элемент
    priority_queue=("${priority_queue[@]:1}")
    priorities=("${priorities[@]:1}")
    
    log "DEBUG" "PRIORITY_DEQUEUE: '$element' (приоритет: $priority, осталось: ${#priority_queue[@]})"
    echo "$element"
}

# Просмотр элемента с высшим приоритетом
priority_peek() {
    if [[ ${#priority_queue[@]} -eq 0 ]]; then
        echo "Ошибка: приоритетная очередь пуста" >&2
        return 1
    fi
    echo "${priority_queue[0]}"
}

# Получение приоритета верхнего элемента
priority_peek_priority() {
    if [[ ${#priorities[@]} -eq 0 ]]; then
        echo "Ошибка: приоритетная очередь пуста" >&2
        return 1
    fi
    echo "${priorities[0]}"
}

# Проверка пустоты
priority_is_empty() {
    [[ ${#priority_queue[@]} -eq 0 ]]
}

# Получение размера
priority_size() {
    echo "${#priority_queue[@]}"
}

# Отображение содержимого с приоритетами
priority_display() {
    if [[ ${#priority_queue[@]} -eq 0 ]]; then
        echo "Приоритетная очередь пуста"
        return
    fi
    
    echo "Приоритетная очередь (элемент -> приоритет):"
    for ((i=0; i<${#priority_queue[@]}; i++)); do
        echo "  ${priority_queue[$i]} -> ${priorities[$i]}"
    done
}

# API функция
priority_queue_api() {
    local command="$1"
    shift
    
    case "$command" in
        "init") init_priority_queue >/dev/null ;;
        "enqueue") priority_enqueue "$1" "$2" >/dev/null ;;
        "dequeue") priority_dequeue ;;
        "peek") priority_peek ;;
        "peek_priority") priority_peek_priority ;;
        "size") priority_size ;;
        "is_empty") priority_is_empty && echo "true" || echo "false" ;;
        "display") priority_display ;;
        *) echo "Неизвестная команда priority_queue: $command" >&2; return 1 ;;
    esac
}

# Если скрипт запущен напрямую
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🎯 Приоритетная очередь"
    echo "Используйте: source priority_queue.sh && priority_queue_api [команда]"
    echo ""
    echo "Пример:"
    echo "  priority_queue_api enqueue 'задача1' 5"
    echo "  priority_queue_api enqueue 'срочная' 1"
    echo "  priority_queue_api dequeue  # вернет 'срочная'"
fi