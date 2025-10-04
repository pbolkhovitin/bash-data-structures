#!/bin/bash
# queue.sh - Реализация очереди (FIFO) на Bash

declare -a queue
declare -i front=0
declare -i rear=0
declare -i size=0

# Оптимизированные операции для очереди
enqueue() {
    queue[rear]="$1"
    ((rear++))
    ((size++))
}

dequeue() {
    if ((size == 0)); then return 1; fi
    local element="${queue[front]}"
    unset queue[front]
    ((front++))
    ((size--))
    echo "$element"
}

# Специфичные для очереди функции
get_front() { echo "${queue[front]}"; }
get_rear() { echo "${queue[rear-1]}"; }