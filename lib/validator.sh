#!/bin/bash

# validator.sh - Валидация входных данных для Bash Data Structures

# Проверка что значение не пустое
validator::not_empty() {
    local value="$1"
    local field_name="${2:-value}"
    
    if [[ -z "$value" ]]; then
        echo "Error: $field_name cannot be empty" >&2
        return 1
    fi
    return 0
}

# Проверка что значение является числом
validator::is_number() {
    local value="$1"
    local field_name="${2:-value}"
    
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        echo "Error: $field_name must be a number" >&2
        return 1
    fi
    return 0
}

# Проверка что значение является положительным числом
validator::is_positive_number() {
    local value="$1"
    local field_name="${2:-value}"
    
    if ! validator::is_number "$value" "$field_name"; then
        return 1
    fi
    
    if [[ $value -lt 0 ]]; then
        echo "Error: $field_name must be positive" >&2
        return 1
    fi
    return 0
}

# Проверка индекса в пределах массива
validator::valid_index() {
    local index="$1"
    local array_size="$2"
    local array_name="${3:-array}"
    
    if ! validator::is_number "$index" "Index"; then
        return 1
    fi
    
    if [[ $index -lt 0 || $index -ge $array_size ]]; then
        echo "Error: Index $index out of bounds for $array_name (size: $array_size)" >&2
        return 1
    fi
    return 0
}

# Проверка что файл существует
validator::file_exists() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        echo "Error: File '$file_path' does not exist" >&2
        return 1
    fi
    return 0
}

# Проверка что файл доступен для чтения
validator::file_readable() {
    local file_path="$1"
    
    if ! validator::file_exists "$file_path"; then
        return 1
    fi
    
    if [[ ! -r "$file_path" ]]; then
        echo "Error: File '$file_path' is not readable" >&2
        return 1
    fi
    return 0
}

# Проверка валидности JSON
validator::is_valid_json() {
    local json_string="$1"
    
    if ! echo "$json_string" | python3 -m json.tool >/dev/null 2>&1; then
        echo "Error: Invalid JSON format" >&2
        return 1
    fi
    return 0
}

# Проверка что команда существует
validator::command_exists() {
    local command_name="$1"
    
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Error: Command '$command_name' not found" >&2
        return 1
    fi
    return 0
}

# Проверка версии Bash
validator::bash_version() {
    local required_version="$1"
    
    if [[ ${BASH_VERSINFO[0]} -lt $required_version ]]; then
        echo "Error: Bash version $required_version+ required (current: ${BASH_VERSION})" >&2
        return 1
    fi
    return 0
}

# Комплексная валидация параметров структуры данных
validator::data_structure_params() {
    local operation="$1"
    local element="$2"
    local index="$3"
    local size="$4"
    
    case "$operation" in
        "push"|"enqueue")
            validator::not_empty "$element" "Element"
            ;;
        "pop"|"dequeue")
            # Не требует дополнительной валидации
            ;;
        "peek"|"front")
            # Не требует дополнительной валидации
            ;;
        "get"|"remove")
            validator::valid_index "$index" "$size" "Structure"
            ;;
        *)
            echo "Error: Unknown operation '$operation'" >&2
            return 1
            ;;
    esac
}

# Экспорт функций
export -f validator::not_empty validator::is_number validator::is_positive_number
export -f validator::valid_index validator::file_exists validator::file_readable
export -f validator::is_valid_json validator::command_exists validator::bash_version
export -f validator::data_structure_params