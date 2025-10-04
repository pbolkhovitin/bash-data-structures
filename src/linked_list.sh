#!/bin/bash

# linked_list.sh - Реализация односвязного списка на Bash

source ../lib/logger.sh
source ../lib/validator.sh

# Структура узла (эмулируем через массивы)
declare -a node_data=()
declare -a node_next=()

# Глобальные переменные
declare -i head_index=-1
declare -i free_list=0
declare -i list_size=0

# Инициализация списка
init_linked_list() {
    node_data=()
    node_next=()
    head_index=-1
    free_list=0
    list_size=0
    
    # Предварительно аллоцируем некоторое пространство
    for ((i=0; i<100; i++)); do
        node_next[$i]=$((i + 1))
    done
    node_next[99]=-1
    
    log "INFO" "Связный список инициализирован"
}

# Создание нового узла
create_node() {
    local data="$1"
    
    if [[ $free_list -eq -1 ]]; then
        log "ERROR" "Недостаточно памяти для нового узла"
        return -1
    fi
    
    local new_node=$free_list
    free_list=${node_next[$free_list]}
    
    node_data[$new_node]="$data"
    node_next[$new_node]=-1
    
    echo $new_node
}

# Добавление в начало
list_add_first() {
    local element="$1"
    if ! validate_element "$element"; then return 1; fi
    
    local new_node=$(create_node "$element")
    if [[ $new_node -eq -1 ]]; then return 1; fi
    
    node_next[$new_node]=$head_index
    head_index=$new_node
    ((list_size++))
    
    log "DEBUG" "LIST_ADD_FIRST: '$element' (размер: $list_size)"
    echo "$element"
}

# Добавление в конец
list_add_last() {
    local element="$1"
    if ! validate_element "$element"; then return 1; fi
    
    local new_node=$(create_node "$element")
    if [[ $new_node -eq -1 ]]; then return 1; fi
    
    if [[ $head_index -eq -1 ]]; then
        head_index=$new_node
    else
        local current=$head_index
        while [[ ${node_next[$current]} -ne -1 ]]; do
            current=${node_next[$current]}
        done
        node_next[$current]=$new_node
    fi
    ((list_size++))
    
    log "DEBUG" "LIST_ADD_LAST: '$element' (размер: $list_size)"
    echo "$element"
}

# Удаление первого элемента
list_remove_first() {
    if [[ $head_index -eq -1 ]]; then
        echo "Ошибка: список пуст" >&2
        return 1
    fi
    
    local element="${node_data[$head_index]}"
    local old_head=$head_index
    head_index=${node_next[$head_index]}
    
    # Возвращаем узел в free list
    node_next[$old_head]=$free_list
    free_list=$old_head
    ((list_size--))
    
    log "DEBUG" "LIST_REMOVE_FIRST: '$element' (размер: $list_size)"
    echo "$element"
}

# Поиск элемента
list_contains() {
    local element="$1"
    local current=$head_index
    local index=0
    
    while [[ $current -ne -1 ]]; do
        if [[ "${node_data[$current]}" == "$element" ]]; then
            echo $index
            return 0
        fi
        current=${node_next[$current]}
        ((index++))
    done
    
    echo "-1"
    return 1
}

# Получение элемента по индексу
list_get() {
    local index="$1"
    
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: индекс должен быть числом" >&2
        return 1
    fi
    
    if [[ $index -lt 0 || $index -ge $list_size ]]; then
        echo "Ошибка: индекс $index вне диапазона [0-$((list_size-1))]" >&2
        return 1
    fi
    
    local current=$head_index
    for ((i=0; i<index; i++)); do
        current=${node_next[$current]}
    done
    
    echo "${node_data[$current]}"
}

# Проверка пустоты
list_is_empty() {
    [[ $head_index -eq -1 ]]
}

# Получение размера
list_size() {
    echo "$list_size"
}

# Отображение списка
list_display() {
    if [[ $head_index -eq -1 ]]; then
        echo "Список пуст"
        return
    fi
    
    echo "Связный список:"
    local current=$head_index
    local index=0
    while [[ $current -ne -1 ]]; do
        echo "  [$index] ${node_data[$current]}"
        current=${node_next[$current]}
        ((index++))
    done
}

# API функция
linked_list_api() {
    local command="$1"
    shift
    
    case "$command" in
        "init") init_linked_list >/dev/null ;;
        "add_first") list_add_first "$1" >/dev/null ;;
        "add_last") list_add_last "$1" >/dev/null ;;
        "remove_first") list_remove_first ;;
        "contains") list_contains "$1" ;;
        "get") list_get "$1" ;;
        "size") list_size ;;
        "is_empty") list_is_empty && echo "true" || echo "false" ;;
        "display") list_display ;;
        *) echo "Неизвестная команда linked_list: $command" >&2; return 1 ;;
    esac
}

# Если скрипт запущен напрямую
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🎯 Связный список"
    echo "Используйте: source linked_list.sh && linked_list_api [команда]"
    echo ""
    echo "Пример:"
    echo "  linked_list_api add_first 'первый'"
    echo "  linked_list_api add_last 'последний'"
    echo "  linked_list_api display"
fi