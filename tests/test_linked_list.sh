#!/bin/bash

# test_linked_list.sh - Тестирование связного списка

source ../lib/tester.sh
source ../src/linked_list.sh

echo "🧪 ТЕСТИРОВАНИЕ СВЯЗНОГО СПИСКА"
echo "==============================="

reset_test_counters

describe "Базовые операции связного списка"

it "Инициализация списка"
linked_list_api init
assert_true "linked_list_api is_empty" "Список должен быть пустым"
assert_equal "0" "$(linked_list_api size)" "Размер должен быть 0"

it "Добавление в начало"
linked_list_api add_first "первый"
linked_list_api add_first "новый_первый"

assert_equal "2" "$(linked_list_api size)" "Размер должен быть 2"
assert_equal "новый_первый" "$(linked_list_api get 0)" "Первый элемент должен быть 'новый_первый'"

it "Добавление в конец"
linked_list_api add_last "последний"
assert_equal "последний" "$(linked_list_api get 2)" "Последний элемент должен быть 'последний'"

it "Поиск элемента"
linked_list_api add_first "для_поиска"
index=$(linked_list_api contains "для_поиска")
assert_equal "0" "$index" "Индекс 'для_поиска' должен быть 0"

not_found=$(linked_list_api contains "несуществующий")
assert_equal "-1" "$not_found" "Не найденный элемент должен возвращать -1"

it "Удаление первого элемента"
linked_list_api add_first "удаляемый"
old_size=$(linked_list_api size)
removed=$(linked_list_api remove_first)

assert_equal "удаляемый" "$removed" "Удаленный элемент должен быть 'удаляемый'"
assert_equal "$((old_size - 1))" "$(linked_list_api size)" "Размер должен уменьшиться на 1"

end_describe