#!/bin/bash

# stack.sh - Чистая реализация стека (LIFO) для Bash Data Structures

# Определение абсолютных путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Загрузка библиотек с проверками
load_library() {
    local lib_file="${PROJECT_ROOT}/lib/$1"
    
    if [[ ! -f "$lib_file" ]]; then
        echo "Error: Library file not found: $lib_file" >&2
        return 1
    fi
    
    source "$lib_file" || {
        echo "Error: Failed to load library: $lib_file" >&2
        return 1
    }
    
    return 0
}

# Загружаем библиотеки
load_library "logger.sh" || exit 1
load_library "validator.sh" || exit 1  
load_library "formatter.sh" || exit 1

# Глобальные переменные стека
declare -a STACK
declare -gi STACK_POINTER=0
declare -g STACK_INITIALIZED=false

# =============================================================================
# ОСНОВНЫЕ ФУНКЦИИ СТЕКА (ЧИСТАЯ РЕАЛИЗАЦИЯ)
# =============================================================================

# Инициализация стека
stack::init() {
    if [[ "$STACK_INITIALIZED" == true ]]; then
        logger::warning "Stack already initialized" "stack"
        return 1
    fi
    
    STACK=()
    STACK_POINTER=0
    STACK_INITIALIZED=true
    
    # Пробуем инициализировать логгер, если не получается - используем временную директорию
    if ! logger::init "stack"; then
        export LOG_DIR="/tmp/bash-ds-logs"
        mkdir -p "$LOG_DIR" 2>/dev/null
        logger::init "stack"
    fi
    
    logger::info "Stack initialized" "stack"
    return 0
}

# Проверка инициализации стека
stack::is_initialized() {
    [[ "$STACK_INITIALIZED" == true ]]
}

# Добавление элемента в стек
stack::push() {
    local element="$1"
    
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if ! validator::not_empty "$element" "Element"; then
        return 1
    fi
    
    STACK[$STACK_POINTER]="$element"
    ((STACK_POINTER++))
    
    logger::debug "PUSH: '$element' (size: $STACK_POINTER)" "stack"
    return 0
}

# Извлечение элемента из стека
stack::pop() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if stack::is_empty; then
        logger::error "Cannot pop from empty stack" "stack"
        return 1
    fi
    
    ((STACK_POINTER--))
    local element="${STACK[$STACK_POINTER]}"
    unset "STACK[$STACK_POINTER]"
    
    logger::debug "POP: '$element' (size: $STACK_POINTER)" "stack"
    
    # Возвращаем элемент ЧЕРЕЗ STDOUT, но с предварительным сохранением
    # Это решает проблему многократного вызова в подстановке команд
    printf '%s' "$element"
    return 0
}

# Просмотр верхнего элемента
stack::peek() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if stack::is_empty; then
        logger::error "Cannot peek empty stack" "stack"
        return 1
    fi
    
    local element="${STACK[$STACK_POINTER-1]}"
    logger::debug "PEEK: '$element'" "stack"
    echo "$element"
    return 0
}

# Проверка пустоты стека
stack::is_empty() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    [[ $STACK_POINTER -eq 0 ]]
}

# Получение размера стека
stack::size() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    logger::debug "SIZE: $STACK_POINTER" "stack"
    echo "$STACK_POINTER"
    return 0
}

# Очистка стека
stack::clear() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    local previous_size=$STACK_POINTER
    STACK=()
    STACK_POINTER=0
    
    logger::info "CLEAR: Stack cleared (was: $previous_size)" "stack"
    echo "$previous_size"
    return 0
}

# Уничтожение стека
stack::destroy() {
    if ! stack::is_initialized; then
        logger::warning "Stack not initialized" "stack"
        return 1
    fi
    
    local previous_size=$STACK_POINTER
    unset STACK
    unset STACK_POINTER
    STACK_INITIALIZED=false
    
    logger::info "DESTROY: Stack destroyed (elements: $previous_size)" "stack"
    echo "Stack destroyed (elements: $previous_size)"
    return 0
}

# =============================================================================
# ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
# =============================================================================

# Поиск элемента в стеке
stack::contains() {
    local element="$1"
    
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if ! validator::not_empty "$element" "Element"; then
        return 1
    fi
    
    for ((i=0; i<STACK_POINTER; i++)); do
        if [[ "${STACK[i]}" == "$element" ]]; then
            logger::debug "CONTAINS: Found '$element' at index $i" "stack"
            echo "$i"
            return 0
        fi
    done
    
    logger::debug "CONTAINS: Element '$element' not found" "stack"
    echo "-1"
    return 1
}

# Получение элемента по индексу
stack::get() {
    local index="$1"
    
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if ! validator::valid_index "$index" "$STACK_POINTER" "Stack"; then
        return 1
    fi
    
    echo "${STACK[index]}"
    return 0
}

# Удаление элемента по индексу
stack::remove() {
    local index="$1"
    
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if ! validator::valid_index "$index" "$STACK_POINTER" "Stack"; then
        return 1
    fi
    
    local element="${STACK[index]}"
    
    # Сдвигаем элементы
    for ((i=index; i<STACK_POINTER-1; i++)); do
        STACK[i]="${STACK[i+1]}"
    done
    
    unset "STACK[STACK_POINTER-1]"
    ((STACK_POINTER--))
    
    logger::debug "REMOVE: Index $index, element '$element' (size: $STACK_POINTER)" "stack"
    echo "$element"
    return 0
}

# =============================================================================
# ФУНКЦИИ ЭКСПОРТА И ПРЕОБРАЗОВАНИЯ
# =============================================================================

# Получение стека как массива
stack::to_array() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if stack::is_empty; then
        return 1
    fi
    
    printf '%s\n' "${STACK[@]}"
    return 0
}

# Получение стека в формате JSON
stack::to_json() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    formatter::json "stack" "${STACK[@]:0:STACK_POINTER}"
}

# Загрузка стека из массива
stack::from_array() {
    local elements=("$@")
    
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if [[ ${#elements[@]} -eq 0 ]]; then
        logger::error "Empty array provided" "stack"
        return 1
    fi
    
    stack::clear >/dev/null
    
    for element in "${elements[@]}"; do
        stack::push "$element" >/dev/null || return 1
    done
    
    logger::info "Loaded ${#elements[@]} elements from array" "stack"
    echo "${#elements[@]}"
    return 0
}

# Отображение стека
stack::display() {
    if ! stack::is_initialized; then
        logger::error "Stack not initialized. Call stack::init first." "stack"
        return 1
    fi
    
    if stack::is_empty; then
        echo "Stack is empty"
        return 1
    fi
    
    echo "Stack contents (LIFO - top to bottom):"
    for ((i=STACK_POINTER-1; i>=0; i--)); do
        echo "  [$i] ${STACK[i]}"
    done
    return 0
}

# =============================================================================
# ЕДИНЫЙ API ДЛЯ ВСЕХ СТРУКТУР ДАННЫХ
# =============================================================================

# Стандартизированный API вызов
stack::api() {
    local command="$1"
    shift
    
    case "$command" in
        "init")
            stack::init
            ;;
        "destroy")
            stack::destroy
            ;;
        "push")
            stack::push "$@"
            ;;
        "pop")
            stack::pop
            ;;
        "peek")
            stack::peek
            ;;
        "size")
            stack::size
            ;;
        "is_empty")
            if stack::is_empty; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        "clear")
            stack::clear
            ;;
        "contains")
            stack::contains "$@"
            ;;
        "get")
            stack::get "$@"
            ;;
        "remove")
            stack::remove "$@"
            ;;
        "to_array")
            stack::to_array
            ;;
        "to_json")
            stack::to_json
            ;;
        "from_array")
            stack::from_array "$@"
            ;;
        "display")
            stack::display
            ;;
        *)
            logger::error "Unknown API command: $command" "stack"
            return 1
            ;;
    esac
}

# =============================================================================
# ТЕСТИРОВАНИЕ С ИСПОЛЬЗОВАНИЕМ TESTER.SH
# =============================================================================

stack::test() {
    source "$(dirname "${BASH_SOURCE[0]}")/../lib/tester.sh"
    
    describe "Stack Implementation Tests"
    
    it "should initialize stack correctly"
    stack::init
    assert_success "stack::is_initialized"
    assert_equal "$(stack::size)" "0"
    assert_equal "$(stack::is_empty)" "true"
    
    it "should push elements to stack"
    stack::push "first"
    assert_success "stack::push 'second'"
    assert_equal "$(stack::size)" "2"
    assert_equal "$(stack::is_empty)" "false"
    
    it "should peek top element"
    assert_equal "$(stack::peek)" "second"
    assert_equal "$(stack::size)" "2" "Size should not change after peek"
    
    it "should pop elements in LIFO order"
    assert_equal "$(stack::pop)" "second"
    assert_equal "$(stack::pop)" "first"
    assert_equal "$(stack::is_empty)" "true"
    
    it "should handle empty stack operations"
    assert_failure "stack::pop"
    assert_failure "stack::peek"
    
    it "should clear stack"
    stack::push "A"
    stack::push "B"
    stack::clear
    assert_equal "$(stack::size)" "0"
    assert_equal "$(stack::is_empty)" "true"
    
    it "should convert to JSON"
    stack::push "test"
    local json=$(stack::to_json)
    assert_contains "$json" '"type": "stack"'
    assert_contains "$json" '"data": ["test"]'
    
    stack::destroy
    end_describe
}

# Авто-инициализация при загрузке в интерактивном режиме
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    stack::init
    echo "Stack module loaded. Use stack::api for operations."
    echo "Run 'stack::test' to execute tests."
fi

# Экспорт функций для использования в других скриптах
export -f stack::init stack::push stack::pop stack::peek stack::is_empty
export -f stack::size stack::clear stack::destroy stack::contains stack::get
export -f stack::remove stack::to_array stack::to_json stack::from_array
export -f stack::display stack::api stack::test stack::is_initialized