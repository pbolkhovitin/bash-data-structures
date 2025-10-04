#!/bin/bash

# priority_queue_demo.sh - Демонстрация приоритетной очереди

echo "🎯 ДЕМОНСТРАЦИЯ ПРИОРИТЕТНОЙ ОЧЕРЕДИ"
echo "==================================="

source ../../src/priority_queue.sh

# Инициализация
priority_queue_api init
echo "✅ Приоритетная очередь инициализирована"

# Добавляем задачи с разными приоритетами
echo ""
echo "📥 Добавление задач с приоритетами:"
priority_queue_api enqueue "Обычная задача" 5
priority_queue_api enqueue "Срочная задача" 1
priority_queue_api enqueue "Важная задача" 3
priority_queue_api enqueue "Очень срочная" 1  # Более высокий приоритет, но добавилась позже

echo "Размер очереди: $(priority_queue_api size)"
echo "Приоритет верхней задачи: $(priority_queue_api peek_priority)"

# Отображаем содержимое
echo ""
echo "📋 Содержимое приоритетной очереди:"
priority_queue_api display

# Обрабатываем задачи в порядке приоритета
echo ""
echo "📤 Обработка задач по приоритету:"
while [[ $(priority_queue_api is_empty) == "false" ]]; do
    task=$(priority_queue_api dequeue)
    priority=$(priority_queue_api peek_priority 2>/dev/null || echo "N/A")
    echo "  Обработана: $task (приоритет: $priority)"
    echo "  Осталось задач: $(priority_queue_api size)"
done

echo ""
echo "✅ Демонстрация завершена!"