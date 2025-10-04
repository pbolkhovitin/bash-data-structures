#!/bin/bash

# test_queue.sh - Комплексное тестирование реализации очереди

source ../lib/tester.sh
source ../src/queue.sh

echo "🧪 ТЕСТИРОВАНИЕ ОЧЕРЕДИ (FIFO)"
echo "=============================="

reset_test_counters

describe "Базовые операции очереди"

it "Инициализация пустой очереди"
queue_api init
assert_true "queue_api is_empty" "Очередь должна быть пустой после инициализации"
assert_equal "0" "$(queue_api size)" "Размер должен быть 0"

it "Добавление одного элемента"
queue_api enqueue "first_task"
assert_equal "false" "$(queue_api is_empty)" "Очередь не должна быть пустой"
assert_equal "1" "$(queue_api size)" "Размер должен быть 1"
assert_equal "first_task" "$(queue_api peek)" "Первый элемент должен быть 'first_task'"

it "Извлечение элемента"
dequeued=$(queue_api dequeue)
assert_equal "first_task" "$dequeued" "Извлеченный элемент должен быть 'first_task'"
assert_equal "true" "$(queue_api is_empty)" "Очередь должна быть пустой после извлечения"
end_describe

describe "Проверка порядка FIFO (First-In-First-Out)"

it "Порядок извлечения соответствует FIFO"
queue_api enqueue "task1"
queue_api enqueue "task2"
queue_api enqueue "task3"

dequeue1=$(queue_api dequeue)
dequeue2=$(queue_api dequeue) 
dequeue3=$(queue_api dequeue)

assert_equal "task1" "$dequeue1" "Первый dequeue должен вернуть 'task1' (первый добавленный)"
assert_equal "task2" "$dequeue2" "Второй dequeue должен вернуть 'task2'"
assert_equal "task3" "$dequeue3" "Третий dequeue должен вернуть 'task3' (последний добавленный)"
assert_equal "true" "$(queue_api is_empty)" "Очередь должна быть пустой"
end_describe

describe "Граничные случаи и обработка ошибок"

it "Dequeue из пустой очереди"
result=$(queue_api dequeue 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустой очереди"

it "Peek пустой очереди"
result=$(queue_api peek 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустой очереди"

it "Добавление пустого элемента"
result=$(queue_api enqueue "" 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'Пустой элемент'" "Должна быть ошибка пустого элемента"
end_describe

describe "Расширенные функции очереди"

it "Отображение содержимого очереди"
queue_api init
queue_api enqueue "job1"
queue_api enqueue "job2"

# Проверяем что display не падает и что-то выводит
output=$(queue_api display)
assert_equal "0" "$?" "Display должен завершаться успешно"
assert_true "[[ -n '$output' ]]" "Display должен выводить содержимое"

it "Множественные операции enqueue/dequeue"
queue_api init
for i in {1..50}; do
    queue_api enqueue "process_$i" > /dev/null
done
assert_equal "50" "$(queue_api size)" "Размер должен быть 50 после 50 enqueue"

for i in {1..50}; do
    dequeued=$(queue_api dequeue)
    assert_equal "process_$i" "$dequeued" "Dequeue должен вернуть process_$i"
done
assert_equal "true" "$(queue_api is_empty)" "Очередь должна быть пустой после всех dequeue"
end_describe

describe "Смешанные операции"

it "Чередование enqueue и dequeue"
queue_api init
queue_api enqueue "A"
queue_api enqueue "B"
dequeue1=$(queue_api dequeue)
queue_api enqueue "C")
queue_api enqueue "D"
dequeue2=$(queue_api dequeue)
dequeue3=$(queue_api dequeue)
dequeue4=$(queue_api dequeue)

assert_equal "A" "$dequeue1" "Первый dequeue должен быть A"
assert_equal "B" "$dequeue2" "Второй dequeue должен быть B" 
assert_equal "C" "$dequeue3" "Третий dequeue должен быть C"
assert_equal "D" "$dequeue4" "Четвертый dequeue должен быть D"

it "Очередь сохраняет порядок при смешанных операциях"
queue_api init
queue_api enqueue "start"
queue_api enqueue "middle"
dequeue1=$(queue_api dequeue)
queue_api enqueue "end"
dequeue2=$(queue_api dequeue)
dequeue3=$(queue_api dequeue)

assert_equal "start" "$dequeue1" "Первый dequeue должен быть 'start'"
assert_equal "middle" "$dequeue2" "Второй dequeue должен быть 'middle'"
assert_equal "end" "$dequeue3" "Третий dequeue должен быть 'end'"
end_describe

describe "Производительность и стабильность"

it "Быстрая обработка множества элементов"
queue_api init
start_time=$(date +%s%N)
for i in {1..1000}; do
    queue_api enqueue "fast_$i" > /dev/null
done
for i in {1..1000}; do
    queue_api dequeue > /dev/null
done
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

assert_true "[[ $duration -lt 5000 ]]" "1000 операций должны выполняться < 5 секунд"
assert_equal "true" "$(queue_api is_empty)" "Очередь должна быть пустой"
end_describe

# Финальные результаты
echo ""
echo "📊 ИТОГИ ТЕСТИРОВАНИЯ ОЧЕРЕДИ:"
end_describe

exit $?