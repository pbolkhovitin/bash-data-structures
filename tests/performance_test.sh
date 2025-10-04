#!/bin/bash

# performance_test.sh - Тестирование производительности для CI/CD

source ../lib/tester.sh
source ../src/stack.sh

echo "⚡ ТЕСТИРОВАНИЕ ПРОИЗВОДИТЕЛЬНОСТИ"
echo "================================"

describe "Быстродействие базовых операций"

it "1000 операций стека за разумное время"
start_time=$(date +%s%N)
stack_api init
for ((i=0; i<1000; i++)); do
    stack_api push "perf_test_$i" > /dev/null
done
for ((i=0; i<1000; i++)); do
    stack_api pop > /dev/null
done
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

# Проверяем что выполняется менее чем за 2 секунды
assert_true "[[ $duration -lt 2000 ]]" "1000 операций должны выполняться < 2с"
end_describe