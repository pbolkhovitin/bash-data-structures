#!/bin/bash

# test_stack.sh - Комплексное тестирование реализации стека
# Соответствует архитектуре проекта bash-data-structures

source ../lib/tester.sh
source ../src/stack.sh

echo "🧪 ТЕСТИРОВАНИЕ СТЕКА (LIFO)"
echo "==========================="

reset_test_counters

# Тестовые данные
TEST_DATA=("apple" "banana" "cherry" "date" "elderberry")

describe "Базовые операции стека"

it "Инициализация пустого стека"
stack::init
assert_true "stack::is_initialized" "Стек должен быть инициализирован"
assert_true "stack::is_empty" "Стек должен быть пустым после инициализации"
assert_equal "0" "$(stack::size)" "Размер должен быть 0"

it "Добавление одного элемента"
stack::push "test_element"
assert_equal "false" "$(stack::is_empty)" "Стек не должен быть пустым"
assert_equal "1" "$(stack::size)" "Размер должен быть 1"
assert_equal "test_element" "$(stack::peek)" "Верхний элемент должен быть 'test_element'"

it "Извлечение элемента"
popped=$(stack::pop)
assert_equal "test_element" "$popped" "Извлеченный элемент должен быть 'test_element'"
assert_equal "true" "$(stack::is_empty)" "Стек должен быть пустым после извлечения"
end_describe

describe "Проверка порядка LIFO (Last-In-First-Out)"

it "Порядок извлечения соответствует LIFO"
stack::push "first"
stack::push "second" 
stack::push "third"

pop1=$(stack::pop)
pop2=$(stack::pop)
pop3=$(stack::pop)

assert_equal "third" "$pop1" "Первый pop должен вернуть 'third' (последний добавленный)"
assert_equal "second" "$pop2" "Второй pop должен вернуть 'second'"
assert_equal "first" "$pop3" "Третий pop должен вернуть 'first' (первый добавленный)"
assert_equal "true" "$(stack::is_empty)" "Стек должен быть пустым"
end_describe

describe "Граничные случаи и обработка ошибок"

it "Pop из пустого стека"
result=$(stack::pop 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_contains "$result" "empty" "Должна быть ошибка пустого стека"

it "Peek пустого стека"
result=$(stack::peek 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_contains "$result" "empty" "Должна быть ошибка пустого стека"

it "Добавление пустого элемента"
result=$(stack::push "" 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_contains "$result" "empty" "Должна быть ошибка пустого элемента"

it "Операции без инициализации"
stack::destroy
result=$(stack::push "test" 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_contains "$result" "initialized" "Должна быть ошибка инициализации"
stack::init
end_describe

describe "Расширенные функции стека"

it "Поиск существующего элемента"
stack::push "apple"
stack::push "banana"
stack::push "cherry"

index=$(stack::contains "banana")
assert_equal "1" "$index" "Индекс 'banana' должен быть 1"

it "Поиск отсутствующего элемента"
not_found=$(stack::contains "orange")
assert_equal "-1" "$not_found" "Не найденный элемент должен возвращать -1"

it "Получение элемента по индексу"
stack::clear
stack::push "first"
stack::push "second"
stack::push "third"

assert_equal "first" "$(stack::get 0)" "Индекс 0 должен быть 'first'"
assert_equal "second" "$(stack::get 1)" "Индекс 1 должен быть 'second'"
assert_equal "third" "$(stack::get 2)" "Индекс 2 должен быть 'third'"

it "Некорректный индекс при получении"
result=$(stack::get 10 2>&1)
exit_code=$?
assert_equal "1" "$exit_code" "Код возврата должен быть 1 при ошибке"
assert_contains "$result" "out of bounds" "Должна быть ошибка выхода за границы"

it "Удаление элемента по индексу"
stack::clear
stack::push "A"
stack::push "B" 
stack::push "C"

removed=$(stack::remove 1)
assert_equal "B" "$removed" "Удаленный элемент должен быть 'B'"
assert_equal "2" "$(stack::size)" "Размер должен уменьшиться до 2"
assert_equal "C" "$(stack::pop)" "Следующий pop должен быть 'C'"
assert_equal "A" "$(stack::pop)" "Последний pop должен быть 'A'"
end_describe

describe "Функции преобразования и экспорта"

it "Преобразование в массив"
stack::clear
stack::push "one"
stack::push "two"

array_output=$(stack::to_array)
assert_contains "$array_output" "one" "Массив должен содержать 'one'"
assert_contains "$array_output" "two" "Массив должен содержать 'two'"
assert_equal "2" "$(echo "$array_output" | wc -l)" "Должно быть 2 строки в выводе"

it "Преобразование в JSON"
stack::clear
stack::push "test_data"

json_output=$(stack::to_json)
assert_contains "$json_output" '"type": "stack"' "JSON должен содержать тип stack"
assert_contains "$json_output" '"data": ["test_data"]' "JSON должен содержать данные"
assert_success "echo '$json_output' | python3 -m json.tool >/dev/null 2>&1" "JSON должен быть валидным"

it "Загрузка из массива"
stack::clear
stack::from_array "item1" "item2" "item3"
assert_equal "3" "$(stack::size)" "Размер должен быть 3 после загрузки"
assert_equal "item3" "$(stack::pop)" "Порядок должен сохраниться"
assert_equal "item2" "$(stack::pop)"
assert_equal "item1" "$(stack::pop)"

it "Отображение содержимого стека"
stack::clear
stack::push "element1"
stack::push "element2"

output=$(stack::display)
assert_equal "0" "$?" "Display должен завершаться успешно"
assert_contains "$output" "element1" "Display должен показывать element1"
assert_contains "$output" "element2" "Display должен показывать element2"
end_describe

describe "Производительность и нагрузочное тестирование"

it "Обработка большого количества элементов"
stack::clear
local count=1000

for ((i=1; i<=count; i++)); do
    stack::push "item_$i" > /dev/null
done

assert_equal "$count" "$(stack::size)" "Размер должен быть $count"

for ((i=count; i>=1; i--)); do
    popped=$(stack::pop)
    assert_equal "item_$i" "$popped" "Pop должен вернуть item_$i"
done

assert_equal "true" "$(stack::is_empty)" "Стек должен быть пустым после всех pop"
end_describe

describe "Совместимость API"

it "Работа через stack::api"
stack::init
stack::api push "api_test"
assert_equal "1" "$(stack::api size)" "API size должен работать"
assert_equal "api_test" "$(stack::api peek)" "API peek должен работать"
assert_equal "api_test" "$(stack::api pop)" "API pop должен работать"
stack::destroy
end_describe

# Финальная очистка
stack::destroy 2>/dev/null || true

# Итоги
echo ""
print_test_summary

exit $?