# API Reference

Полная документация по API всех структур данных в проекте.

## 📋 Общие соглашения

### Формат вызова
```bash
source src/structure.sh
structure_api команда [аргументы]
```

### Возвращаемые значения
- **Успех**: Команда возвращает `0` и выводит результат в stdout
- **Ошибка**: Команда возвращает `1` и выводит сообщение об ошибке в stderr

### Логирование
Все операции логируются через `lib/logger.sh`. Уровень логирования настраивается через переменную `LOG_LEVEL`.

## 🥞 Стек (Stack) - `src/stack.sh`

LIFO (Last-In-First-Out) структура данных.

### Команды

#### `init`
Инициализирует пустой стек.

**Пример:**
```bash
stack_api init
```

#### `push element`
Добавляет элемент на вершину стека.

**Аргументы:**
- `element` - Данные для добавления

**Возвращает:** Добавленный элемент

**Пример:**
```bash
stack_api push "Hello World"
```

#### `pop`
Удаляет и возвращает элемент с вершины стека.

**Возвращает:** Удаленный элемент

**Ошибка:** Если стек пуст

**Пример:**
```bash
element=$(stack_api pop)
```

#### `peek`
Возвращает элемент с вершины стека без удаления.

**Возвращает:** Верхний элемент

**Ошибка:** Если стек пуст

**Пример:**
```bash
top_element=$(stack_api peek)
```

#### `size`
Возвращает количество элементов в стеке.

**Возвращает:** Число элементов

**Пример:**
```bash
count=$(stack_api size)
```

#### `is_empty`
Проверяет, пуст ли стек.

**Возвращает:** `true` если пуст, `false` если нет

**Пример:**
```bash
if [[ $(stack_api is_empty) == "true" ]]; then
    echo "Стек пуст"
fi
```

#### `contains element`
Проверяет наличие элемента в стеке.

**Аргументы:**
- `element` - Элемент для поиска

**Возвращает:** Индекс элемента или `-1` если не найден

**Пример:**
```bash
index=$(stack_api contains "искомый_элемент")
```

#### `display`
Отображает содержимое стека.

**Пример:**
```bash
stack_api display
```

## 📊 Очередь (Queue) - `src/queue.sh`

FIFO (First-In-First-Out) структура данных.

### Команды

#### `init`
Инициализирует пустую очередь.

```bash
queue_api init
```

#### `enqueue element`
Добавляет элемент в конец очереди.

**Аргументы:**
- `element` - Данные для добавления

**Возвращает:** Добавленный элемент

```bash
queue_api enqueue "задача"
```

#### `dequeue`
Удаляет и возвращает элемент из начала очереди.

**Возвращает:** Удаленный элемент

**Ошибка:** Если очередь пуста

```bash
task=$(queue_api dequeue)
```

#### `peek`
Возвращает элемент из начала очереди без удаления.

**Возвращает:** Первый элемент

**Ошибка:** Если очередь пуста

```bash
next=$(queue_api peek)
```

#### `size`
Возвращает количество элементов в очереди.

**Возвращает:** Число элементов

```bash
length=$(queue_api size)
```

#### `is_empty`
Проверяет, пуста ли очередь.

**Возвращает:** `true` если пуста, `false` если нет

```bash
queue_api is_empty
```

#### `display`
Отображает содержимое очереди.

```bash
queue_api display
```

## 🔄 Двусторонняя очередь (Deque) - `src/deque.sh`

Double-ended queue - поддерживает добавление/удаление с обоих концов.

### Команды

#### `init`
Инициализирует пустой deque.

```bash
deque_api init
```

#### `add_front element`
Добавляет элемент в начало.

```bash
deque_api add_front "первый"
```

#### `add_rear element`
Добавляет элемент в конец.

```bash
deque_api add_rear "последний"
```

#### `remove_front`
Удаляет и возвращает элемент из начала.

**Возвращает:** Удаленный элемент

```bash
front=$(deque_api remove_front)
```

#### `remove_rear`
Удаляет и возвращает элемент из конца.

**Возвращает:** Удаленный элемент

```bash
rear=$(deque_api remove_rear)
```

#### `peek_front`
Возвращает элемент из начала без удаления.

**Возвращает:** Первый элемент

```bash
deque_api peek_front
```

#### `peek_rear`
Возвращает элемент из конца без удаления.

**Возвращает:** Последний элемент

```bash
deque_api peek_rear
```

#### `size`
Возвращает количество элементов.

```bash
deque_api size
```

#### `is_empty`
Проверяет, пуст ли deque.

```bash
deque_api is_empty
```

## 🎯 Приоритетная очередь (Priority Queue) - `src/priority_queue.sh`

Элементы с высшим приоритетом извлекаются первыми.

### Команды

#### `init`
Инициализирует пустую приоритетную очередь.

```bash
priority_queue_api init
```

#### `enqueue element priority`
Добавляет элемент с указанным приоритетом.

**Аргументы:**
- `element` - Данные для добавления
- `priority` - Числовой приоритет (меньше = выше приоритет)

**Возвращает:** Добавленный элемент

```bash
priority_queue_api enqueue "срочная задача" 1
priority_queue_api enqueue "обычная задача" 5
```

#### `dequeue`
Удаляет и возвращает элемент с высшим приоритетом.

**Возвращает:** Элемент с наивысшим приоритетом

```bash
task=$(priority_queue_api dequeue)  # вернет "срочная задача"
```

#### `peek`
Возвращает элемент с высшим приоритетом без удаления.

**Возвращает:** Элемент с наивысшим приоритетом

```bash
priority_queue_api peek
```

#### `peek_priority`
Возвращает приоритет верхнего элемента.

**Возвращает:** Числовой приоритет

```bash
priority=$(priority_queue_api peek_priority)
```

#### `size`
Возвращает количество элементов.

```bash
priority_queue_api size
```

#### `is_empty`
Проверяет, пуста ли очередь.

```bash
priority_queue_api is_empty
```

#### `display`
Отображает содержимое с приоритетами.

```bash
priority_queue_api display
```

## 🔗 Связный список (Linked List) - `src/linked_list.sh`

Динамическая структура данных с последовательным доступом.

### Команды

#### `init`
Инициализирует пустой список.

```bash
linked_list_api init
```

#### `add_first element`
Добавляет элемент в начало списка.

```bash
linked_list_api add_first "новый первый"
```

#### `add_last element`
Добавляет элемент в конец списка.

```bash
linked_list_api add_last "новый последний"
```

#### `remove_first`
Удаляет и возвращает первый элемент.

**Возвращает:** Удаленный элемент

```bash
first=$(linked_list_api remove_first)
```

#### `contains element`
Проверяет наличие элемента в списке.

**Аргументы:**
- `element` - Элемент для поиска

**Возвращает:** Индекс элемента или `-1` если не найден

```bash
index=$(linked_list_api contains "искомый")
```

#### `get index`
Возвращает элемент по индексу.

**Аргументы:**
- `index` - Числовой индекс (0-based)

**Возвращает:** Элемент по указанному индексу

```bash
element=$(linked_list_api get 2)
```

#### `size`
Возвращает количество элементов.

```bash
linked_list_api size
```

#### `is_empty`
Проверяет, пуст ли список.

```bash
linked_list_api is_empty
```

#### `display`
Отображает содержимое списка.

```bash
linked_list_api display
```

## 🛠️ Вспомогательные библиотеки

### Логирование (`lib/logger.sh`)

```bash
source lib/logger.sh

log "INFO" "Информационное сообщение"
log "ERROR" "Сообщение об ошибке"
log "DEBUG" "Отладочная информация"

# JSON логирование
log_json "INFO" "Событие" '{"user":"john","action":"login"}'

# Настройка уровня логирования
export LOG_LEVEL="DEBUG"
```

### Тестирование (`lib/tester.sh`)

```bash
source lib/tester.sh

describe "Группа тестов"
it "Конкретный тест"
assert_equal "ожидаемое" "фактическое" "Сообщение"
assert_true "условие" "Сообщение"
end_describe
```

### Валидация (`lib/validator.sh`)

```bash
source lib/validator.sh

validate_element "данные"
validate_index "5" "10"
validate_filename "file.txt"
sanitized=$(sanitize_string "$user_input")
```

## 🎯 Примеры использования

### Обработка задач с приоритетами
```bash
source src/priority_queue.sh

priority_queue_api init
priority_queue_api enqueue "критический баг" 1
priority_queue_api enqueue "новая фича" 3
priority_queue_api enqueue "рефакторинг" 5

# Обработка в порядке приоритета
while [[ $(priority_queue_api is_empty) == "false" ]]; do
    task=$(priority_queue_api dequeue)
    echo "Обрабатываю: $task"
done
```

### Система отмены действий (Undo/Redo)
```bash
source src/stack.sh

undo_stack=$(mktemp)
redo_stack=$(mktemp)

# Сохранение состояния
stack_api push "состояние1" > "$undo_stack"

# Отмена действия
if [[ -s "$undo_stack" ]]; then
    state=$(stack_api pop < "$undo_stack")
    stack_api push "$state" > "$redo_stack"
    echo "Восстановлено: $state"
fi
```

### Обработка логов в реальном времени
```bash
source src/queue.sh

queue_api init
tail -f /var/log/app.log | while read line; do
    queue_api enqueue "$line"
    
    if [[ $(queue_api size) -gt 100 ]]; then
        # Пакетная обработка
        while [[ $(queue_api is_empty) == "false" ]]; do
            log_line=$(queue_api dequeue)
            process_log "$log_line"
        done
    fi
done
```

## ⚡ Советы по производительности

1. **Используйте массивы Bash** - они быстрее чем эмуляция через строки
2. **Избегайте подпроцессов** в циклах обработки
3. **Используйте локальные переменные** с `local`
4. **Минимизируйте вызовы внешних команд** в горячих путях

## 🔧 Отладка

### Включение детального логирования
```bash
export LOG_LEVEL="DEBUG"
export LOG_FILE="/tmp/bash-ds-debug.log"
```

### Проверка состояния структур
```bash
# Для любой структуры
structure_api display
structure_api size
structure_api is_empty
```

---

**Примечание:** Все структуры данных потокобезопасны для использования в отдельных процессах, но не для параллельного использования в одном процессе Bash.
