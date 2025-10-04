#!/bin/bash

# stress_test.sh - Нагрузочное тестирование структур данных

source ../lib/tester.sh
source ../src/stack.sh
source ../src/queue.sh
source ../src/priority_queue.sh
source ../src/linked_list.sh

echo "🔥 НАГРУЗОЧНОЕ ТЕСТИРОВАНИЕ"
echo "==========================="

describe "Нагрузочное тестирование стека (5000 операций)"

it "Обработка большого объема данных"
stack_api init
for ((i=0; i<5000; i++)); do
    stack_api push "stress_element_$i" > /dev/null
done
assert_equal "5000" "$(stack_api size)" "Размер должен быть 5000"

# Извлекаем все элементы
for ((i=0; i<5000; i++)); do
    stack_api pop > /dev/null
done
assert_equal "true" "$(stack_api is_empty)" "Стек должен быть пустым"
end_describe

describe "Нагрузочное тестирование очереди"

it "Многопоточная симуляция (быстрая)"
queue_api init
for ((i=0; i<3000; i++)); do
    queue_api enqueue "task_$i" > /dev/null
done
assert_equal "3000" "$(queue_api size)" "Размер должен быть 3000"
end_describe