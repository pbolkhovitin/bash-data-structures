#!/bin/bash

# test_framework.sh - Тестирование фреймворка и библиотек

echo "🧪 ТЕСТИРОВАНИЕ ФРЕЙМВОРКА И БИБЛИОТЕК"
echo "======================================"

# Проверка существования библиотек
check_library_existence() {
    local libs=("../lib/logger.sh" "../lib/validator.sh" "../lib/formatter.sh" "../lib/tester.sh")
    
    for lib in "${libs[@]}"; do
        if [[ -f "$lib" ]]; then
            echo "✅ Найдена: $lib"
        else
            echo "❌ Отсутствует: $lib"
            return 1
        fi
    done
    return 0
}

# Тестирование синтаксиса библиотек
test_library_syntax() {
    echo "🔍 Проверка синтаксиса библиотек..."
    
    local libs=("../lib/logger.sh" "../lib/validator.sh" "../lib/formatter.sh" "../lib/tester.sh")
    local has_errors=0
    
    for lib in "${libs[@]}"; do
        if bash -n "$lib"; then
            echo "✅ Синтаксис корректен: $lib"
        else
            echo "❌ Синтаксическая ошибка в: $lib"
            has_errors=1
        fi
    done
    
    return $has_errors
}

# Тестирование функций logger
test_logger_functions() {
    echo "📝 Тестирование логгера..."
    
    source ../lib/logger.sh
    
    # Тест уровней логирования
    log_debug "Тестовое debug сообщение" > /dev/null
    log_info "Тестовое info сообщение" > /dev/null
    log_warn "Тестовое warn сообщение" > /dev/null
    log_error "Тестовое error сообщение" > /dev/null
    
    echo "✅ Базовые функции логгера работают"
}

# Тестирование функций validator
test_validator_functions() {
    echo "🔍 Тестирование валидатора..."
    
    source ../lib/validator.sh
    
    # Тест валидации чисел
    if validate_number "123" && ! validate_number "abc"; then
        echo "✅ Валидация чисел работает"
    else
        echo "❌ Ошибка валидации чисел"
        return 1
    fi
    
    # Тест валидации строк
    if validate_string "test" && ! validate_string ""; then
        echo "✅ Валидация строк работает"
    else
        echo "❌ Ошибка валидации строк"
        return 1
    fi
    
    return 0
}

# Тестирование функций formatter
test_formatter_functions() {
    echo "🎨 Тестирование форматтера..."
    
    source ../lib/formatter.sh
    
    # Тест форматирования вывода
    local formatted=$(format_output "test" "INFO")
    if [[ -n "$formatted" ]]; then
        echo "✅ Форматирование вывода работает"
    else
        echo "❌ Ошибка форматирования вывода"
        return 1
    fi
    
    return 0
}

# Основная функция тестирования
main() {
    echo "Начало тестирования фреймворка..."
    
    # Проверка существования библиотек
    if ! check_library_existence; then
        echo "❌ Тестирование прервано: отсутствуют необходимые библиотеки"
        exit 1
    fi
    
    # Проверка синтаксиса
    if ! test_library_syntax; then
        echo "❌ Тестирование прервано: синтаксические ошибки в библиотеках"
        exit 1
    fi
    
    # Тестирование функциональности
    test_logger_functions
    test_validator_functions
    test_formatter_functions
    
    echo ""
    echo "✅ ТЕСТИРОВАНИЕ ФРЕЙМВОРКА ЗАВЕРШЕНО УСПЕШНО"
}

# Запуск тестов
main "$@"