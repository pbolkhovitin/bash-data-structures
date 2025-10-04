#!/bin/bash

# test_stack.sh - Комплексное тестирование реализации стека

source ../lib/tester.sh
source ../src/stack.sh

echo "🧪 ТЕСТИРОВАНИЕ СТЕКА (LIFO)"
echo "==========================="

reset_test_counters

describe "Базовые операции стека"

it "Инициализация пустого стека"
stack_api init
assert_true "stack_api is_empty" "Стек должен быть пустым после инициализации"
assert_equal "0" "$(stack_api size)" "Размер должен быть 0"

it "Добавление одного элемента"
stack_api push "test_element"
assert_equal "false" "$(stack_api is_empty)" "Стек не должен быть пустым"
assert_equal "1" "$(stack_api size)" "Размер должен быть 1"
assert_equal "test_element" "$(stack_api peek)" "Верхний элемент должен быть 'test_element'"

it "Извлечение элемента"
popped=$(stack_api pop)
assert_equal "test_element" "$popped" "Извлеченный элемент должен быть 'test_element'"
assert_equal "true" "$(stack_api is_empty)" "Стек должен быть пустым после извлечения"
end_describe

describe "Проверка порядка LIFO (Last-In-First-Out)"

it "Порядок извлечения соответствует LIFO"
stack_api push "first"
stack_api push "second" 
stack_api push "third"

pop1=$(stack_api pop)
pop2=$(stack_api pop)
pop3=$(stack_api pop)

assert_equal "third" "$pop1" "Первый pop должен вернуть 'third' (последний добавленный)"
assert_equal "second" "$pop2" "Второй pop должен вернуть 'second'"
assert_equal "first" "$pop3" "Третий pop должен вернуть 'first' (первый добавленный)"
assert_equal "true" "$(stack_api is_empty)" "Стек должен быть пустым"
end_describe

describe "Граничные случаи и обработка ошибок"

it "Pop из пустого стека"
result=$(stack_api pop 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого стека"

it "Peek пустого стека"
result=$(stack_api peek 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'пуст'" "Должна быть ошибка пустого стека"

it "Добавление пустого элемента"
result=$(stack_api push "" 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_true "echo '$result' | grep -q 'Пустой элемент'" "Должна быть ошибка пустого элемента"
end_describe

describe "Расширенные функции стека"

it "Поиск существующего элемента"
stack_api push "apple"
stack_api push "banana"
stack_api push "cherry"

index=$(stack_api contains "banana")
assert_equal "1" "$index" "Индекс 'banana' должен быть 1"

it "Поиск отсутствующего элемента"
not_found=$(stack_api contains "orange")
assert_equal "-1" "$not_found" "Не найденный элемент должен возвращать -1"

it "Отображение содержимого стека"
stack_api init
stack_api push "element1"
stack_api push "element2"

# Проверяем что display не падает и что-то выводит
output=$(stack_api display)
assert_equal "0" "$?" "Display должен завершаться успешно"
assert_true "[[ -n '$output' ]]" "Display должен выводить содержимое"

it "Множественные операции push/pop"
stack_api init
for i in {1..100}; do
    stack_api push "item_$i" > /dev/null
done
assert_equal "100" "$(stack_api size)" "Размер должен быть 100 после 100 push"

for i in {100..1}; do
    popped=$(stack_api pop)
    assert_equal "item_$i" "$popped" "Pop должен вернуть item_$i"
done
assert_equal "true" "$(stack_api is_empty)" "Стек должен быть пустым после всех pop"
end_describe

describe "Смешанные операции"

it "Чередование push и pop"
stack_api init
stack_api push "A"
stack_api push "B"
pop1=$(stack_api pop)
stack_api push "C"
stack_api push "D"
pop2=$(stack_api pop)
pop3=$(stack_api pop)
pop4=$(stack_api pop)

assert_equal "B" "$pop1" "Первый pop должен быть B"
assert_equal "D" "$pop2" "Второй pop должен быть D" 
assert_equal "C" "$pop3" "Третий pop должен быть C"
assert_equal "A" "$pop4" "Четвертый pop должен быть A"
end_describe

# Финальные результаты
echo ""
echo "📊 ИТОГИ ТЕСТИРОВАНИЯ СТЕКА:"
end_describe

exit $?