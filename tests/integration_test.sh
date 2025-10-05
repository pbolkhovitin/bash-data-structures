#!/bin/bash

# integration_test.sh - Интеграционные тесты всей системы

echo "🔗 ИНТЕГРАЦИОННЫЕ ТЕСТЫ СИСТЕМЫ"
echo "================================"

# Импорт библиотек
source ../lib/logger.sh
source ../lib/validator.sh
source ../lib/tester.sh

# Тест взаимодействия стек + логгер
test_stack_with_logging() {
    echo "🧪 Тест: Стек с интегрированным логированием"
    
    source ../src/stack.sh
    
    # Создаем временный файл для логов
    local temp_log="/tmp/stack_integration_test.log"
    
    # Тестируем операции стека с логированием
    stack_api init
    stack_api push "integration_test_1"
    stack_api push "integration_test_2"
    
    local popped=$(stack_api pop)
    
    if [[ "$popped" == "integration_test_2" ]]; then
        echo "✅ Интеграция стека и базовых операций работает"
        return 0
    else
        echo "❌ Ошибка интеграции стека"
        return 1
    fi
}

# Тест взаимодействия нескольких структур данных
test_multiple_structures() {
    echo "🧪 Тест: Взаимодействие нескольких структур данных"
    
    source ../src/stack.sh
    source ../src/queue.sh
    
    # Тест передачи данных между стеком и очередью
    stack_api init
    queue_api init
    
    stack_api push "data_from_stack"
    queue_api enqueue "data_from_queue"
    
    local stack_data=$(stack_api pop)
    local queue_data=$(queue_api dequeue)
    
    if [[ "$stack_data" == "data_from_stack" && "$queue_data" == "data_from_queue" ]]; then
        echo "✅ Взаимодействие структур данных работает"
        return 0
    else
        echo "❌ Ошибка взаимодействия структур данных"
        return 1
    fi
}

# Тест системы валидации во всех структурах
test_validation_system() {
    echo "🧪 Тест: Система валидации во всех компонентах"
    
    local structures=("stack" "queue" "deque")
    local all_valid=true
    
    for structure in "${structures[@]}"; do
        source "../src/${structure}.sh"
        
        # Тестируем валидацию пустых элементов
        local result=$("${structure}_api" init 2>/dev/null; "${structure}_api" push "" 2>&1)
        
        if echo "$result" | grep -q "Пустой элемент\|empty\|invalid"; then
            echo "✅ Валидация в $structure работает"
        else
            echo "❌ Проблема с валидацией в $structure"
            all_valid=false
        fi
    done
    
    $all_valid
}

# Тест производительности системы
test_system_performance() {
    echo "🧪 Тест: Производительность системы"
    
    source ../src/stack.sh
    source ../src/queue.sh
    
    local start_time=$(date +%s%N)
    
    # Интенсивные операции с разными структурами
    stack_api init
    queue_api init
    
    for i in {1..100}; do
        stack_api push "item_$i" > /dev/null
        queue_api enqueue "item_$i" > /dev/null
    done
    
    for i in {1..100}; do
        stack_api pop > /dev/null
        queue_api dequeue > /dev/null
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    if [[ $duration -lt 5000 ]]; then
        echo "✅ Производительность системы в норме: ${duration}ms"
        return 0
    else
        echo "⚠️  Производительность системы медленная: ${duration}ms"
        return 1
    fi
}

# Тест обработки ошибок в системе
test_error_handling() {
    echo "🧪 Тест: Обработка ошибок в системе"
    
    source ../src/stack.sh
    
    # Тест операции на пустой структуре
    local result=$(stack_api pop 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$result" | grep -q "пуст\|empty"; then
        echo "✅ Обработка ошибок работает"
        return 0
    else
        echo "❌ Проблема с обработкой ошибок"
        return 1
    fi
}

# Основная функция тестирования
main() {
    echo "Запуск интеграционных тестов..."
    
    local tests_passed=0
    local tests_total=5
    
    # Запуск всех интеграционных тестов
    test_stack_with_logging && ((tests_passed++))
    test_multiple_structures && ((tests_passed++))
    test_validation_system && ((tests_passed++))
    test_system_performance && ((tests_passed++))
    test_error_handling && ((tests_passed++))
    
    echo ""
    echo "📊 РЕЗУЛЬТАТЫ ИНТЕГРАЦИОННЫХ ТЕСТОВ:"
    echo "✅ Пройдено: $tests_passed/$tests_total"
    
    if [[ $tests_passed -eq $tests_total ]]; then
        echo "🎉 ВСЕ ИНТЕГРАЦИОННЫЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО"
        return 0
    else
        echo "❌ НЕКОТОРЫЕ ТЕСТЫ НЕ ПРОЙДЕНЫ"
        return 1
    fi
}

# Запуск тестов
main "$@"