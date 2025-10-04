#!/bin/bash

# Конфигурация
readonly STACK_LOG="stack.log"
readonly MAX_LOG_SIZE=1048576  # 1MB

# Глобальные переменные стека
declare -a stack
declare -i stack_pointer=0

# Инициализация логирования
init_logging() {
    rotate_logs
    log "INFO" "Стек инициализирован"
}

# Умное логирование с ротацией
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$STACK_LOG"
    
    if [[ -f "$STACK_LOG" ]]; then
        local file_size=$(stat -c%s "$STACK_LOG" 2>/dev/null || stat -f%z "$STACK_LOG" 2>/dev/null)
        if [[ $file_size -gt $MAX_LOG_SIZE ]]; then
            rotate_logs
        fi
    fi
}

# Ротация логов
rotate_logs() {
    if [[ -f "$STACK_LOG" ]]; then
        local timestamp=$(date '+%Y%m%d_%H%M%S')
        mv "$STACK_LOG" "${STACK_LOG}.${timestamp}" 2>/dev/null
        find . -name "${STACK_LOG}.*" -mtime +5 -delete 2>/dev/null
    fi
}

# =============================================================================
# ОСНОВНЫЕ ФУНКЦИИ СТЕКА (API для скриптов)
# =============================================================================

# Функция для проверки пустоты стека
is_empty() {
    [[ $stack_pointer -eq 0 ]]
}

# Функция добавления элемента в стек (push) - LIFO
push() {
    local element="$1"
    
    if [[ -z "$element" ]]; then
        echo "Ошибка: пустой элемент" >&2
        return 1
    fi
    
    stack[$stack_pointer]="$element"
    ((stack_pointer++))
    
    log "DEBUG" "PUSH: '$element' (размер: $stack_pointer)"
    return 0
}

# Функция извлечения элемента из стека (pop) - LIFO
pop() {
    if is_empty; then
        echo "Ошибка: стек пуст" >&2
        return 1
    fi
    
    ((stack_pointer--))
    local element="${stack[stack_pointer]}"
    unset "stack[stack_pointer]"
    
    log "DEBUG" "POP: '$element' (размер: $stack_pointer)"
    echo "$element"
    return 0
}

# Функция просмотра верхнего элемента (peek)
peek() {
    if is_empty; then
        echo "Ошибка: стек пуст" >&2
        return 1
    fi
    
    local element="${stack[stack_pointer-1]}"
    log "DEBUG" "PEEK: '$element'"
    echo "$element"
    return 0
}

# Функция получения размера стека
size() {
    log "DEBUG" "SIZE: $stack_pointer"
    echo "$stack_pointer"
    return 0
}

# Функция отображения всего стека
display() {
    if is_empty; then
        return 1
    fi
    
    log "DEBUG" "DISPLAY: отображение стека (размер: $stack_pointer)"
    for ((i=stack_pointer-1; i>=0; i--)); do
        echo "${stack[i]}"
    done
    return 0
}

# Функция очистки стека
clear_stack() {
    local previous_size=$stack_pointer
    stack=()
    stack_pointer=0
    
    log "INFO" "CLEAR: стек очищен (было: $previous_size)"
    echo "$previous_size"
    return 0
}

# Функция поиска элемента в стеке
contains() {
    local element="$1"
    
    if [[ -z "$element" ]]; then
        echo "Ошибка: пустой элемент для поиска" >&2
        return 1
    fi
    
    for ((i=0; i<stack_pointer; i++)); do
        if [[ "${stack[i]}" == "$element" ]]; then
            log "DEBUG" "CONTAINS: найден '$element' по индексу $i"
            echo "$i"
            return 0
        fi
    done
    
    log "DEBUG" "CONTAINS: элемент '$element' не найден"
    echo "-1"
    return 1
}

# Функция удаления элемента по индексу
remove_at() {
    local index="$1"
    
    if [[ -z "$index" ]] || ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: неверный индекс" >&2
        return 1
    fi
    
    if (( index < 0 || index >= stack_pointer )); then
        echo "Ошибка: индекс $index вне диапазона [0-$((stack_pointer-1))]" >&2
        return 1
    fi
    
    local element="${stack[index]}"
    
    # Сдвигаем элементы
    for ((i=index; i<stack_pointer-1; i++)); do
        stack[i]="${stack[i+1]}"
    done
    
    unset "stack[stack_pointer-1]"
    ((stack_pointer--))
    
    log "DEBUG" "REMOVE_AT: индекс $index, элемент '$element' (размер: $stack_pointer)"
    echo "$element"
    return 0
}

# Функция получения элемента по индексу
get_at() {
    local index="$1"
    
    if [[ -z "$index" ]] || ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: неверный индекс" >&2
        return 1
    fi
    
    if (( index < 0 || index >= stack_pointer )); then
        echo "Ошибка: индекс $index вне диапазона [0-$((stack_pointer-1))]" >&2
        return 1
    fi
    
    echo "${stack[index]}"
    return 0
}

# =============================================================================
# РАСШИРЕННЫЕ ФУНКЦИИ ДЛЯ СКРИПТОВ
# =============================================================================

# Функция проверки существования стека
stack_exists() {
    [[ -v stack ]] && [[ -v stack_pointer ]]
}

# Функция инициализации стека (явная инициализация)
init_stack() {
    if stack_exists; then
        echo "Предупреждение: стек уже инициализирован" >&2
        return 1
    fi
    
    declare -ag stack=()
    declare -gi stack_pointer=0
    init_logging
    echo "Стек инициализирован"
    return 0
}

# Функция деинициализации стека
destroy_stack() {
    if ! stack_exists; then
        echo "Предупреждение: стек не инициализирован" >&2
        return 1
    fi
    
    local previous_size=$stack_pointer
    unset stack
    unset stack_pointer
    
    log "INFO" "DESTROY: стек уничтожен (было элементов: $previous_size)"
    echo "Стек уничтожен (элементов: $previous_size)"
    return 0
}

# Функция получения всего стека как массива
get_stack_array() {
    if is_empty; then
        return 1
    fi
    
    printf '%s\n' "${stack[@]}"
    return 0
}

# Функция получения стека в формате JSON
get_stack_json() {
    if is_empty; then
        echo '{"stack": [], "size": 0, "empty": true}'
        return 0
    fi
    
    local json='{"stack": ['
    for ((i=0; i<stack_pointer; i++)); do
        if (( i > 0 )); then
            json+=','
        fi
        # Экранируем специальные символы для JSON
        local escaped_element=$(printf '%s' "${stack[i]}" | sed 's/"/\\"/g')
        json+="\"$escaped_element\""
    done
    json+="], \"size\": $stack_pointer, \"empty\": false}"
    
    echo "$json"
    return 0
}

# Функция загрузки стека из массива
load_from_array() {
    local elements=("$@")
    
    if [[ ${#elements[@]} -eq 0 ]]; then
        echo "Ошибка: пустой массив для загрузки" >&2
        return 1
    fi
    
    clear_stack >/dev/null
    
    for element in "${elements[@]}"; do
        push "$element" >/dev/null
    done
    
    log "INFO" "LOAD_FROM_ARRAY: загружено ${#elements[@]} элементов"
    echo "Загружено ${#elements[@]} элементов"
    return 0
}

# Функция загрузки стека из файла (по одному элементу на строку)
load_from_file() {
    local filename="$1"
    
    if [[ ! -f "$filename" ]]; then
        echo "Ошибка: файл '$filename' не найден" >&2
        return 1
    fi
    
    local count=0
    clear_stack >/dev/null
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Пропускаем пустые строки и комментарии
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        if push "$line" >/dev/null; then
            ((count++))
        fi
    done < "$filename"
    
    log "INFO" "LOAD_FROM_FILE: загружено $count элементов из '$filename'"
    echo "$count"
    return 0
}

# Функция сохранения стека в файл
save_to_file() {
    local filename="${1:-stack_data.txt}"
    
    if is_empty; then
        echo "Ошибка: стек пуст, сохранение невозможно" >&2
        return 1
    fi
    
    {
        echo "# Сохранение стека $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# Размер: $stack_pointer"
        for ((i=stack_pointer-1; i>=0; i--)); do
            echo "${stack[i]}"
        done
    } > "$filename"
    
    log "INFO" "SAVE_TO_FILE: стек сохранен в '$filename'"
    echo "$filename"
    return 0
}

# Функция копирования стека
copy_stack() {
    if is_empty; then
        echo "Ошибка: стек пуст, копирование невозможно" >&2
        return 1
    fi
    
    local copy=("${stack[@]}")
    printf '%s\n' "${copy[@]}"
    return 0
}

# Функция проверки идентичности двух стеков (для тестирования)
stacks_equal() {
    local stack1=("${!1}")
    local stack2=("${!2}")
    
    if [[ ${#stack1[@]} -ne ${#stack2[@]} ]]; then
        return 1
    fi
    
    for ((i=0; i<${#stack1[@]}; i++)); do
        if [[ "${stack1[i]}" != "${stack2[i]}" ]]; then
            return 1
        fi
    done
    
    return 0
}

# =============================================================================
# ФУНКЦИИ ЭКСПОРТА/ИМПОРТА
# =============================================================================

# Функция экспорта стека в файл
export_stack() {
    local filename="${1:-stack_export.txt}"
    
    if is_empty; then
        echo "Ошибка: экспорт невозможен - стек пуст" >&2
        return 1
    fi
    
    {
        echo "# Экспорт стека $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# Размер: $stack_pointer"
        echo "# Порядок: LIFO (последний вошел - первый вышел)"
        for ((i=stack_pointer-1; i>=0; i--)); do
            echo "${stack[i]}"
        done
    } > "$filename"
    
    log "INFO" "EXPORT: стек экспортирован в '$filename'"
    echo "$filename"
    return 0
}

# Функция импорта стека из файла
import_stack() {
    local filename="$1"
    
    if [[ ! -f "$filename" ]]; then
        echo "Ошибка: файл '$filename' не найден" >&2
        return 1
    fi
    
    local count=0
    local temp_stack=()
    local temp_pointer=0
    
    # Читаем файл и сохраняем во временный массив
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] || [[ -z "$line" ]] && continue
        
        temp_stack[temp_pointer]="$line"
        ((temp_pointer++))
    done < "$filename"
    
    # Очищаем текущий стек
    local previous_size=$stack_pointer
    clear_stack >/dev/null
    
    # Добавляем элементы в обратном порядке для сохранения LIFO
    for ((i=temp_pointer-1; i>=0; i--)); do
        push "${temp_stack[i]}" >/dev/null
        ((count++))
    done
    
    log "INFO" "IMPORT: импортировано $count элементов (было: $previous_size)"
    echo "$count"
    return 0
}

# =============================================================================
# РЕЖИМ КОМАНДНОЙ СТРОКИ (ДЛЯ СКРИПТОВ)
# =============================================================================

# Функция для использования стека в скриптах (бесшумный режим)
stack_api() {
    local command="$1"
    shift
    
    case "$command" in
        "init")
            init_stack >/dev/null
            return $?
            ;;
        "destroy")
            destroy_stack >/dev/null
            return $?
            ;;
        "push")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            push "$1" >/dev/null
            return $?
            ;;
        "pop")
            pop 2>/dev/null
            return $?
            ;;
        "peek")
            peek 2>/dev/null
            return $?
            ;;
        "size")
            size 2>/dev/null
            return $?
            ;;
        "is_empty")
            if is_empty; then
                echo "true"
            else
                echo "false"
            fi
            return 0
            ;;
        "clear")
            clear_stack >/dev/null
            return $?
            ;;
        "contains")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            contains "$1" 2>/dev/null
            return $?
            ;;
        "get")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            get_at "$1" 2>/dev/null
            return $?
            ;;
        "remove")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            remove_at "$1" >/dev/null
            return $?
            ;;
        "get_array")
            get_stack_array
            return $?
            ;;
        "get_json")
            get_stack_json
            return $?
            ;;
        "load_array")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            load_from_array "$@" >/dev/null
            return $?
            ;;
        "load_file")
            if [[ $# -eq 0 ]]; then
                return 1
            fi
            load_from_file "$1" >/dev/null
            return $?
            ;;
        "save_file")
            save_to_file "$1" >/dev/null
            return $?
            ;;
        "copy")
            copy_stack
            return $?
            ;;
        *)
            echo "Неизвестная команда API: $command" >&2
            return 1
            ;;
    esac
}

# =============================================================================
# ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ В СКРИПТАХ
# =============================================================================

# Функция демонстрации использования API
show_api_examples() {
    cat << 'EOF'
Примеры использования стека в скриптах:

1. Базовые операции:
   #!/bin/bash
   source steck.sh
   stack_api push "элемент1"
   stack_api push "элемент2"
   size=$(stack_api size)
   top=$(stack_api peek)
   popped=$(stack_api pop)

2. Обработка в цикле:
   #!/bin/bash
   source steck.sh
   stack_api push "A"
   stack_api push "B" 
   stack_api push "C"
   
   while ! stack_api is_empty; do
       item=$(stack_api pop)
       echo "Обрабатываем: $item"
   done

3. Работа с массивами:
   #!/bin/bash
   source steck.sh
   data=("один" "два" "три")
   stack_api load_array "${data[@]}"
   stack_array=$(stack_api get_array)

4. Сохранение/загрузка:
   #!/bin/bash  
   source steck.sh
   stack_api push "данные"
   stack_api save_file "backup.txt"
   stack_api clear
   stack_api load_file "backup.txt"

5. JSON экспорт:
   #!/bin/bash
   source steck.sh
   stack_api push "test"
   json_data=$(stack_api get_json)
   echo "$json_data"

Для использования в своих скриптах:
   source /path/to/steck.sh
   # Используйте функции stack_api
EOF
}

# =============================================================================
# ТЕСТИРОВАНИЕ И ИНТЕРАКТИВНЫЙ РЕЖИМ
# =============================================================================

# Комплексные юнит-тесты
run_tests() {
    echo "=== ЗАПУСК ТЕСТОВ СТЕКА ==="
    local passed=0
    local total=0
    
    # Сохраняем текущее состояние стека
    local original_stack=("${stack[@]}")
    local original_pointer=$stack_pointer
    
    # Тест 1: Инициализация пустого стека
    echo -n "Тест 1: Инициализация пустого стека... "
    clear_stack >/dev/null
    if is_empty && [[ $(stack_api size) -eq 0 ]]; then
        echo "✅ ПРОЙДЕН"
        ((passed++))
    else
        echo "❌ НЕ ПРОЙДЕН"
    fi
    ((total++))
    
    # Тест 2: Добавление элемента
    echo -n "Тест 2: Добавление элемента... "
    clear_stack >/dev/null
    stack_api push "test1" >/dev/null
    if [[ $(stack_api peek) == "test1" ]] && [[ $(stack_api size) -eq 1 ]]; then
        echo "✅ ПРОЙДЕН"
        ((passed++))
    else
        echo "❌ НЕ ПРОЙДЕН"
    fi
    ((total++))
    
    # Тест 3: Удаление элемента
    echo -n "Тест 3: Удаление элемента... "
    clear_stack >/dev/null
    stack_api push "test1" >/dev/null
    local popped=$(stack_api pop)
    if [[ "$popped" == "test1" ]] && [[ $(stack_api is_empty) == "true" ]]; then
        echo "✅ ПРОЙДЕН"
        ((passed++))
    else
        echo "❌ НЕ ПРОЙДЕН"
    fi
    ((total++))
    
    # Тест API функций
    echo -n "Тест 4: API функции... "
    clear_stack >/dev/null
    stack_api push "api_test" >/dev/null
    local api_size=$(stack_api size)
    local api_empty=$(stack_api is_empty)
    local api_peek=$(stack_api peek)
    if [[ $api_size -eq 1 && $api_empty == "false" && $api_peek == "api_test" ]]; then
        echo "✅ ПРОЙДЕН"
        ((passed++))
    else
        echo "❌ НЕ ПРОЙДЕН"
    fi
    ((total++))
    
    # Восстанавливаем оригинальное состояние
    stack=("${original_stack[@]}")
    stack_pointer=$original_pointer
    
    # Итоги
    echo "=== РЕЗУЛЬТАТЫ ТЕСТОВ ==="
    echo "Пройдено: $passed/$total"
    
    if [[ $passed -eq $total ]]; then
        echo "🎉 Все тесты успешно пройдены!"
        log "INFO" "TEST: Все тесты пройдены ($passed/$total)"
        return 0
    else
        echo "💥 Тесты не пройдены: $((total - passed)) ошибок"
        log "WARNING" "TEST: Тесты не пройдены ($passed/$total)"
        return 1
    fi
}

# Функция справки
show_help() {
    cat << 'EOF'
Использование: $0 [КОМАНДА] [АРГУМЕНТ]  # Интерактивный режим
Использование: source steck.sh && stack_api [КОМАНДА] [АРГУМЕНТ]  # Для скриптов

📚 Команды стека (LIFO):
  push <элемент>      - добавить элемент в стек
  pop                 - извлечь верхний элемент
  peek               - посмотреть верхний элемент
  display            - показать содержимое стека
  size               - показать размер стека
  clear              - очистить стек
  is_empty           - проверить пустоту стека
  contains <элемент> - найти элемент в стеке
  remove <индекс>    - удалить элемент по индексу
  get <индекс>       - получить элемент по индексу
  export [файл]      - экспортировать стек в файл
  import <файл>      - импортировать стек из файла
  test               - запустить тесты
  examples           - показать примеры использования API
  log                - показать логи
  help               - показать эту справку

🎯 API для скриптов:
  stack_api init          - инициализировать стек
  stack_api push <elem>   - добавить элемент
  stack_api pop           - извлечь элемент
  stack_api peek          - посмотреть верхний элемент
  stack_api size          - получить размер
  stack_api is_empty      - проверить пустоту
  stack_api get_json      - получить стек как JSON
  stack_api load_array <elements> - загрузить из массива
  stack_api save_file <file> - сохранить в файл

💡 Пример использования в скрипте:
  #!/bin/bash
  source steck.sh
  stack_api push "данные"
  stack_api push "тест"
  echo "Размер: $(stack_api size)"
  echo "Верхний: $(stack_api peek)"
EOF
}

# Обработка команд в интерактивном режиме
process_command() {
    case "$1" in
        "push")
            if [[ -z "$2" ]]; then
                echo "Ошибка: для push требуется элемент" >&2
                return 1
            fi
            if push "$2"; then
                echo "✅ Элемент '$2' добавлен в стек"
            fi
            ;;
        "pop")
            local element
            element=$(pop)
            if [[ $? -eq 0 ]]; then
                echo "✅ Элемент '$element' удален из стека"
            else
                echo "❌ Стек пуст, удаление невозможно"
            fi
            ;;
        "peek")
            local element
            element=$(peek)
            if [[ $? -eq 0 ]]; then
                echo "🔍 Верхний элемент: $element"
            else
                echo "❌ Стек пуст"
            fi
            ;;
        "display")
            if display; then
                echo "📋 Содержимое стека (LIFO - сверху вниз):"
            else
                echo "📭 Стек пуст"
            fi
            ;;
        "size")
            local stack_size
            stack_size=$(size)
            echo "📊 Размер стека: $stack_size"
            ;;
        "clear")
            local previous_size
            previous_size=$(clear_stack)
            echo "🧹 Стек очищен (удалено элементов: $previous_size)"
            ;;
        "is_empty")
            if is_empty; then
                echo "📭 Стек пуст"
            else
                echo "📦 Стек не пуст (элементов: $(size))"
            fi
            ;;
        "contains")
            if [[ -z "$2" ]]; then
                echo "Ошибка: для contains требуется элемент" >&2
                return 1
            fi
            local index
            index=$(contains "$2")
            if [[ $? -eq 0 ]]; then
                echo "🔎 Элемент '$2' найден по индексу: $index"
            else
                echo "🔎 Элемент '$2' не найден в стеке"
            fi
            ;;
        "remove")
            if [[ -z "$2" ]]; then
                echo "Ошибка: для remove требуется индекс" >&2
                return 1
            fi
            local element
            element=$(remove_at "$2")
            if [[ $? -eq 0 ]]; then
                echo "🗑️ Элемент '$element' удален по индексу $2"
            fi
            ;;
        "get")
            if [[ -z "$2" ]]; then
                echo "Ошибка: для get требуется индекс" >&2
                return 1
            fi
            local element
            element=$(get_at "$2")
            if [[ $? -eq 0 ]]; then
                echo "📄 Элемент по индексу $2: $element"
            fi
            ;;
        "export")
            local filename
            filename=$(export_stack "$2")
            if [[ $? -eq 0 ]]; then
                echo "💾 Стек экспортирован в '$filename'"
            fi
            ;;
        "import")
            if [[ -z "$2" ]]; then
                echo "Ошибка: для import требуется имя файла" >&2
                return 1
            fi
            local count
            count=$(import_stack "$2")
            if [[ $? -eq 0 ]]; then
                echo "📥 Импортировано $count элементов"
            fi
            ;;
        "test")
            run_tests
            ;;
        "examples")
            show_api_examples
            ;;
        "log")
            if [[ -f "$STACK_LOG" ]]; then
                echo "=== ПОСЛЕДНИЕ ЗАПИСИ ЛОГА ==="
                tail -10 "$STACK_LOG"
            else
                echo "Лог-файл не найден"
            fi
            ;;
        "help")
            show_help
            ;;
        *)
            echo "Неизвестная команда: $1" >&2
            echo "Используйте: help для списка команд" >&2
            return 1
            ;;
    esac
}

# Интерактивный режим
interactive_mode() {
    echo "🎯 УПРАВЛЕНИЕ СТЕКОМ (LIFO) - API ДЛЯ СКРИПТОВ"
    echo "────────────────────────────────────"
    echo "💾 Логи: $STACK_LOG"
    echo "❓ Введите 'help' для справки, 'examples' для примеров API"
    echo
    
    while true; do
        read -e -p "stack> " command arg1 arg2
        
        case "${command:-}" in
            "push"|"p")
                if [[ -z "$arg1" ]]; then
                    read -p "Введите элемент: " arg1
                fi
                process_command "push" "$arg1"
                ;;
            "pop"|"o")
                process_command "pop"
                ;;
            "peek"|"e")
                process_command "peek"
                ;;
            "display"|"d")
                process_command "display"
                ;;
            "size"|"s")
                process_command "size"
                ;;
            "clear"|"c")
                process_command "clear"
                ;;
            "is_empty"|"i")
                process_command "is_empty"
                ;;
            "contains"|"f")
                if [[ -z "$arg1" ]]; then
                    read -p "Введите элемент для поиска: " arg1
                fi
                process_command "contains" "$arg1"
                ;;
            "remove"|"r")
                if [[ -z "$arg1" ]]; then
                    read -p "Введите индекс для удаления: " arg1
                fi
                process_command "remove" "$arg1"
                ;;
            "get"|"g")
                if [[ -z "$arg1" ]]; then
                    read -p "Введите индекс: " arg1
                fi
                process_command "get" "$arg1"
                ;;
            "export"|"x")
                process_command "export" "$arg1"
                ;;
            "import"|"m")
                process_command "import" "$arg1"
                ;;
            "test"|"t")
                process_command "test"
                ;;
            "examples"|"ex")
                process_command "examples"
                ;;
            "log"|"l")
                process_command "log"
                ;;
            "help"|"h"|"?")
                process_command "help"
                ;;
            "exit"|"quit"|"q")
                echo "👋 Завершение работы"
                break
                ;;
            "")
                continue
                ;;
            *)
                echo "❓ Неизвестная команда: $command"
                echo "💡 Введите 'help' для списка команд"
                ;;
        esac
    done
}

# Основная функция
main() {
    # Инициализация
    init_logging
    
    # Обработка сигналов для корректного завершения
    trap 'log "INFO" "Скрипт завершен"; exit 0' INT TERM
    
    # Запуск в соответствующем режиме
    if [[ $# -gt 0 ]]; then
        if [[ "$1" == "--api" ]]; then
            # Режим API для скриптов
            shift
            stack_api "$@"
        else
            # Обычный интерактивный режим
            process_command "$@"
        fi
    else
        interactive_mode
    fi
}

# Точка входа
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi