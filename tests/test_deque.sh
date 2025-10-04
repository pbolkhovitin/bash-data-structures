#!/bin/bash

# test_deque.sh - Комплексное тестирование реализации двусторонней очереди

source ../lib/tester.sh
source ../src/deque.sh

echo "🧪 ТЕСТИРОВАНИЕ DEQUE (ДВУСТОРОННЯЯ ОЧЕРЕДЬ)"
echo "==========================================="

reset_test_counters

describe "Базовые операции Deque"

it "Инициализация пустого deque"
deque_api init
assert_true "deque_api is_empty" "Deque должен быть пустым после инициализации"
assert_equal "0" "$(deque_api size)" "Размер должен быть 0"

it "Добавление в начало"
deque_api add_front "front_element"
assert_equal "false" "$(deque_api is_empty)" "Deque не должен быть пустым"
assert_equal "1" "$(deque_api size)" "Размер должен быть 1"
assert_equal "front_element" "$(deque_api peek_front)" "Передний элемент должен быть 'front_element'"

it "Добавление в конец"
deque_api add_rear "rear_element"
assert_equal "2" "$(deque_api size)" "Размер должен быть 2"
assert_equal "rear_element" "$(deque_api peek_rear)" "Задний элемент должен быть 'rear_element'"
end_describe

describe "Двусторонние операции"

it "Удаление с начала"
deque_api init
deque_api add_front "to_remove_front"
removed=$(deque_api remove_front)
assert_equal "to_remove_front" "$removed" "Удаленный элемент должен быть 'to_remove_front'"
assert_equal "true" "$(deque_api is_empty)" "Deque должен быть пустым"

it "Удаление с конца"
deque_api init
deque_api add_rear "to_remove_rear"
removed=$(deque_api remove_rear)
assert_equal "to_remove_rear" "$removed" "Удаленный элемент должен быть 'to_remove_rear'"
assert_equal "true" "$(deque_api is_empty)" "Deque должен быть пустым"

it "Комбинированные операции с обоих концов"
deque_api init
deque_api add_front "A"
deque_api add_rear "B"
deque_api add_front "C"
deque_api add_rear "D"

assert_equal "4" "$(deque_api size)" "Размер должен быть 4"

front1=$(deque_api remove_front)
rear1=$(deque_api remove_rear)
front2=$(deque_api remove_front)
rear2=$(deque_api remove_rear)

assert_equal "C" "$front1" "Первый remove_front должен быть 'C'"
assert_equal "D" "$rear1" "Первый remove_rear должен быть 'D'"
assert_equal "A" "$front2" "Второй remove_front должен быть 'A'"
assert_equal "B" "$rear2" "Второй remove_rear должен быть 'B'"
end_describe

describe "Граничные случаи и обработка ошибок"

it "Remove_front из пустого deque"
result=$(deque_api remove_front 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого deque"

it "Remove_rear из пустого deque"
result=$(deque_api remove_rear 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого deque"

it "Peek_front пустого deque"
result=$(deque_api peek_front 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого deque"

it "Peek_rear пустого deque"
result=$(deque_api peek_rear 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого deque"

it "Добавление пустого элемента"
result=$(deque_api add_front "" 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'Пустой элемент'" "Должна быть ошибка пустого элемента"
end_describe

describe "Сложные сценарии использования"

it "Deque как стек (использование только одного конца)"
deque_api init
# Используем только rear операции как стек
deque_api add_rear "push1"
deque_api add_rear "push2")
deque_api add_rear "push3"

pop1=$(deque_api remove_rear)
pop2=$(deque_api remove_rear)
pop3=$(deque_api remove_rear)

assert_equal "push3" "$pop1" "Первый remove_rear должен быть 'push3'"
assert_equal "push2" "$pop2" "Второй remove_rear должен быть 'push2'"
assert_equal "push1" "$pop3" "Третий remove_rear должен быть 'push1'"

it "Deque как очередь (использование разных концов)"
deque_api init
# Используем как очередь: add_rear + remove_front
deque_api add_rear "enqueue1"
deque_api add_rear "enqueue2"
deque_api add_rear "enqueue3"

dequeue1=$(deque_api remove_front)
dequeue2=$(deque_api remove_front)
dequeue3=$(deque_api remove_front)

assert_equal "enqueue1" "$dequeue1" "Первый remove_front должен быть 'enqueue1'"
assert_equal "enqueue2" "$dequeue2" "Второй remove_front должен быть 'enqueue2'"
assert_equal "enqueue3" "$dequeue3" "Третий remove_front должен быть 'enqueue3'"

it "Симметричные операции"
deque_api init
deque_api add_front "X"
deque_api add_rear "Y"
deque_api add_front "Z"

assert_equal "Z" "$(deque_api peek_front)" "Peek_front должен быть 'Z'"
assert_equal "Y" "$(deque_api peek_rear)" "Peek_rear должен быть 'Y'"
assert_equal "3" "$(deque_api size)" "Размер должен быть 3"
end_describe

describe "Производительность Deque"

it "Эффективность двусторонних операций"
deque_api init
start_time=$(date +%s%N)

# Чередуем операции с обоих концов
for i in {1..250}; do
    deque_api add_front "front_$i" > /dev/null
    deque_api add_rear "rear_$i" > /dev/null
done

assert_equal "500" "$(deque_api size)" "Размер должен быть 500 после 500 операций"

# Извлекаем с обоих концов
for i in {250..1}; do
    deque_api remove_front > /dev/null
    deque_api remove_rear > /dev/null
done

end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

assert_true "[[ $duration -lt 10000 ]]" "1000 операций должны выполняться < 10 секунд"
assert_equal "true" "$(deque_api is_empty)" "Deque должен быть пустым"
end_describe

describe "Специфичные для Deque тесты"

it "Порядок элементов при сложных операциях"
deque_api init
deque_api add_front "A")
deque_api add_rear "B"
deque_api add_front "C"
deque_api add_rear "D"

# Ожидаемый порядок: C, A, B, D
assert_equal "C" "$(deque_api peek_front)" "Front должен быть C"
assert_equal "D" "$(deque_api peek_rear)" "Rear должен быть D"

deque_api remove_front  # Убираем C
assert_equal "A" "$(deque_api peek_front)" "Теперь front должен быть A"
assert_equal "D" "$(deque_api peek_rear)" "Rear все еще должен быть D"

deque_api remove_rear  # Убираем D
assert_equal "A" "$(deque_api peek_front)" "Front все еще должен быть A"
assert_equal "B" "$(deque_api peek_rear)" "Теперь rear должен быть B"
end_describe

# Финальные результаты
echo ""
echo "📊 ИТОГИ ТЕСТИРОВАНИЯ DEQUE:"
end_describe

exit $?