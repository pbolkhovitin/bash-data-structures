#!/bin/bash

# test_priority_queue.sh - Тестирование приоритетной очереди

source ../lib/tester.sh
source ../src/priority_queue.sh

echo "🧪 ТЕСТИРОВАНИЕ ПРИОРИТЕТНОЙ ОЧЕРЕДИ"
echo "==================================="

reset_test_counters

describe "Базовые операции приоритетной очереди"

it "Инициализация очереди"
priority_queue_api init
assert_true "priority_queue_api is_empty" "Очередь должна быть пустой"
assert_equal "0" "$(priority_queue_api size)" "Размер должен быть 0"

it "Добавление элементов с разными приоритетами"
priority_queue_api enqueue "низкий" 10
priority_queue_api enqueue "высокий" 1
priority_queue_api enqueue "средний" 5

assert_equal "3" "$(priority_queue_api size)" "Размер должен быть 3"
assert_equal "высокий" "$(priority_queue_api peek)" "Верхний элемент должен быть 'высокий'"

it "Порядок извлечения по приоритету"
first=$(priority_queue_api dequeue)
second=$(priority_queue_api dequeue)
third=$(priority_queue_api dequeue)

assert_equal "высокий" "$first" "Первый dequeue должен вернуть 'высокий'"
assert_equal "средний" "$second" "Второй dequeue должен вернуть 'средний'"
assert_equal "низкий" "$third" "Третий dequeue должен вернуть 'низкий'"

it "Элементы с одинаковым приоритетом"
priority_queue_api enqueue "первый" 5
priority_queue_api enqueue "второй" 5
priority_queue_api enqueue "третий" 5

first=$(priority_queue_api dequeue)
assert_equal "первый" "$first" "При одинаковом приоритете должен соблюдаться FIFO"

end_describe