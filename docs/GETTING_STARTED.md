# Руководство по началу работы 🚀

Полное пошаговое руководство по установке и использованию Bash Data Structures в ваших проектах.

## 📋 Содержание

1. [Требования](#-требования)
2. [Установка](#-установка)
3. [Быстрый старт](#-быстрый-старт)
4. [Основные концепции](#-основные-концепции)
5. [Практические примеры](#-практические-примеры)
6. [Интеграция в проекты](#-интеграция-в-проекты)
7. [Отладка и логирование](#-отладка-и-логирование)
8. [Следующие шаги](#-следующие-шаги)

## 🛠 Требования

### Минимальные требования
- **Bash 4.0+** (рекомендуется 4.4+)
- **Linux/macOS/WSL** с базовыми утилитами
- **GNU Coreutils** (стандартный набор)

### Проверка версии Bash
```bash
bash --version
# GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
```

### Проверка совместимости
```bash
# Запустите скрипт проверки
./utils/dependency_check.sh

# Или проверьте вручную
command -v bash >/dev/null && echo "Bash найден" || echo "Bash не установлен"
[[ $BASH_VERSINFO -ge 4 ]] && echo "Версия подходящая" || echo "Требуется Bash 4.0+"
```

## 📦 Установка

### Способ 1: Клонирование репозитория (рекомендуется)
```bash
# Клонируйте репозиторий
git clone https://github.com/your-username/bash-data-structures.git
cd bash-data-structures

# Установите зависимости и сделайте скрипты исполняемыми
make install

# Проверьте установку
make test
```

### Способ 2: Как подмодуль Git
```bash
# В вашем проекте
git submodule add https://github.com/your-username/bash-data-structures.git lib/bash-ds
cd lib/bash-ds
make install
```

### Способ 3: Ручная установка
```bash
# Просто скопируйте нужные файлы в ваш проект
cp -r bash-data-structures/src/ /path/to/your/project/lib/
cp -r bash-data-structures/lib/ /path/to/your/project/lib/
```

## 🎯 Быстрый старт

### Ваш первый скрипт со стеком

Создайте файл `my_first_stack.sh`:

```bash
#!/bin/bash

# Загружаем библиотеку стека
source /path/to/bash-data-structures/src/stack.sh

# Инициализируем стек
stack_api init

echo "🎯 Демонстрация работы стека (LIFO)"
echo "==================================="

# Добавляем элементы
stack_api push "Первый элемент"
stack_api push "Второй элемент" 
stack_api push "Третий элемент"

# Показываем состояние
echo "Размер стека: $(stack_api size)"
echo "Верхний элемент: $(stack_api peek)"

echo ""
echo "📤 Извлекаем элементы в порядке LIFO:"
while [[ $(stack_api is_empty) == "false" ]]; do
    element=$(stack_api pop)
    echo "  Извлечен: $element"
done

echo ""
echo "✅ Готово! Стек пуст: $(stack_api is_empty)"
```

Запустите скрипт:
```bash
chmod +x my_first_stack.sh
./my_first_stack.sh
```

### Работа с очередью

Создайте `my_first_queue.sh`:

```bash
#!/bin/bash

source /path/to/bash-data-structures/src/queue.sh

queue_api init

echo "🎯 Демонстрация работы очереди (FIFO)"
echo "====================================="

# Симуляция обработки задач
queue_api enqueue "Задача 1: Анализ логов"
queue_api enqueue "Задача 2: Очистка кэша" 
queue_api enqueue "Задача 3: Резервное копирование"

echo "Очередь задач:"
queue_api display

echo ""
echo "🔄 Обработка задач в порядке FIFO:"
while [[ $(queue_api is_empty) == "false" ]]; do
    task=$(queue_api dequeue)
    echo "  Обрабатываю: $task"
    sleep 1  # Имитация обработки
done

echo "✅ Все задачи обработаны!"
```

## 🧠 Основные концепции

### 1. Единый API интерфейс

Все структуры данных используют единый формат вызова:
```bash
structure_api команда [аргументы]
```

### 2. Стандартные команды

Большинство структур поддерживают базовый набор команд:

| Команда | Описание | Пример |
|---------|-----------|---------|
| `init` | Инициализация | `stack_api init` |
| `size` | Размер структуры | `queue_api size` |
| `is_empty` | Проверка пустоты | `stack_api is_empty` |
| `display` | Отображение содержимого | `deque_api display` |

### 3. Обработка ошибок

Все функции возвращают код ошибки:
```bash
if ! stack_api push "данные"; then
    echo "Ошибка добавления элемента!" >&2
    exit 1
fi

# Или перехватывайте stderr
element=$(stack_api pop 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo "Не удалось извлечь элемент"
fi
```

### 4. Логирование

Система автоматически логирует операции:
```bash
# Настройка уровня логирования
export LOG_LEVEL="DEBUG"
export LOG_FILE="/tmp/myapp.log"

source src/stack.sh
stack_api push "тест"  # Запись в лог
```

## 🔧 Практические примеры

### Пример 1: Система отмены действий (Undo/Redo)

```bash
#!/bin/bash

source src/stack.sh

# Стек для отмены и повторения
UNDO_STACK=$(mktemp)
REDO_STACK=$(mktemp)

# Функция сохранения состояния
save_state() {
    local state="$1"
    stack_api push "$state" > "$UNDO_STACK"
    # Очищаем стек redo при новом действии
    stack_api init > "$REDO_STACK"
}

# Функция отмены
undo() {
    if [[ -s "$UNDO_STACK" ]]; then
        local state=$(stack_api pop < "$UNDO_STACK")
        stack_api push "$state" > "$REDO_STACK"
        echo "Отменено. Восстановлено состояние: $state"
        return 0
    else
        echo "Нечего отменять"
        return 1
    fi
}

# Функция повтора
redo() {
    if [[ -s "$REDO_STACK" ]]; then
        local state=$(stack_api pop < "$REDO_STACK")
        stack_api push "$state" > "$UNDO_STACK"
        echo "Повторено. Восстановлено состояние: $state"
        return 0
    else
        echo "Нечего повторять"
        return 1
    fi
}

# Демонстрация
echo "🧪 Демонстрация Undo/Redo системы"
echo "================================"

save_state "Состояние 1"
save_state "Состояние 2" 
save_state "Состояние 3"

undo  # Вернет "Состояние 2"
undo  # Вернет "Состояние 1"
redo  # Вернет "Состояние 2"
```

### Пример 2: Обработчик задач с приоритетами

```bash
#!/bin/bash

source src/priority_queue.sh

priority_queue_api init

echo "🎯 Система управления задачами с приоритетами"
echo "============================================"

# Добавляем задачи с разными приоритетами
priority_queue_api enqueue "Критический баг: падение сервера" 1
priority_queue_api enqueue "Добавить новую фичу" 3
priority_queue_api enqueue "Рефакторинг кода" 5
priority_queue_api enqueue "Срочное обновление безопасности" 1

echo "Текущие задачи:"
priority_queue_api display

echo ""
echo "🔄 Обработка задач по приоритету:"
while [[ $(priority_queue_api is_empty) == "false" ]]; do
    task=$(priority_queue_api dequeue)
    priority=$(priority_queue_api peek_priority 2>/dev/null || echo "N/A")
    echo "  ✅ Обработано: $task"
    echo "     Осталось задач: $(priority_queue_api size)"
    echo ""
done
```

### Пример 3: Калькулятор обратной польской нотации

```bash
#!/bin/bash

source src/stack.sh

rpn_calculate() {
    local expression="$1"
    stack_api init
    
    echo "🧮 Вычисление: $expression"
    
    IFS=' ' read -ra tokens <<< "$expression"
    
    for token in "${tokens[@]}"; do
        case "$token" in
            [0-9]*)
                stack_api push "$token"
                ;;
            [+\\-*/])
                local b=$(stack_api pop)
                local a=$(stack_api pop)
                
                case "$token" in
                    "+") result=$((a + b)) ;;
                    "-") result=$((a - b)) ;;
                    "*") result=$((a * b)) ;;
                    "/") result=$((a / b)) ;;
                esac
                
                stack_api push "$result"
                ;;
        esac
    done
    
    echo "🎯 Результат: $(stack_api pop)"
}

# Примеры использования
rpn_calculate "3 4 +"           # 7
rpn_calculate "5 1 2 + 4 * +"   # 17
rpn_calculate "15 7 1 1 + - /"  # 3
```

## 🏗 Интеграция в проекты

### Интеграция в существующий Bash-скрипт

```bash
#!/bin/bash
# existing_script.sh

# --- Конфигурация ---
BASH_DS_PATH="/opt/bash-data-structures"
LOG_FILE="/var/log/myapp/operations.log"

# --- Загрузка библиотек ---
source "$BASH_DS_PATH/src/queue.sh"
source "$BASH_DS_PATH/src/stack.sh"
source "$BASH_DS_PATH/lib/logger.sh"

# --- Настройка логирования ---
export LOG_LEVEL="INFO"
export LOG_FILE

# --- Основная логика ---
process_data() {
    local data_file="$1"
    local temp_stack=$(mktemp)
    
    # Чтение файла в стек
    while IFS= read -r line; do
        stack_api push "$line" > "$temp_stack"
    done < "$data_file"
    
    # Обработка в обратном порядке
    while [[ $(stack_api is_empty < "$temp_stack") == "false" ]]; do
        local line=$(stack_api pop < "$temp_stack")
        process_line "$line"
    done
    
    rm "$temp_stack"
}
```

### Создание системы обработки логов

```bash
#!/bin/bash
# log_processor.sh

source src/queue.sh
source lib/logger.sh

# Очередь для буферизации логов
LOG_QUEUE=$(mktemp)

# Инициализация
queue_api init > "$LOG_QUEUE"
export LOG_LEVEL="DEBUG"

process_log_line() {
    local line="$1"
    queue_api enqueue "$line" < "$LOG_QUEUE" > "$LOG_QUEUE"
    
    # Пакетная обработка каждые 100 строк
    if [[ $(queue_api size < "$LOG_QUEUE") -ge 100 ]]; then
        process_batch
    fi
}

process_batch() {
    local batch_file=$(mktemp)
    
    while [[ $(queue_api is_empty < "$LOG_QUEUE") == "false" ]]; do
        queue_api dequeue < "$LOG_QUEUE" >> "$batch_file"
    done
    
    # Обработка батча
    if [[ -s "$batch_file" ]]; then
        analyze_logs "$batch_file"
        log "INFO" "Обработано $(wc -l < "$batch_file") строк логов"
    fi
    
    rm "$batch_file"
}
```

## 🔍 Отладка и логирование

### Включение детального логирования

```bash
# Максимальная детализация
export LOG_LEVEL="DEBUG"
export LOG_FILE="/tmp/bash-ds-debug.log"

# Очистка старого лога
> "$LOG_FILE"

# Запуск с логированием
source src/stack.sh
stack_api push "test element"

# Просмотр лога
tail -f "$LOG_FILE"
```

### Отладочный скрипт

```bash
#!/bin/bash
# debug_helper.sh

debug_structure() {
    local structure="$1"
    local operation="$2"
    
    echo "🔍 Отладка: $structure.$operation"
    echo "Лог файл: $LOG_FILE"
    echo ""
    
    # Показываем последние записи лога
    if [[ -f "$LOG_FILE" ]]; then
        echo "Последние записи лога:"
        tail -10 "$LOG_FILE"
    fi
}

# Использование
export LOG_LEVEL="DEBUG"
source src/stack.sh

stack_api push "debug test"
debug_structure "stack" "push"
```

### Проверка состояния структур

```bash
#!/bin/bash
# status_check.sh

check_structure_status() {
    local structure="$1"
    
    echo "📊 Статус $structure:"
    echo "  Размер: $(${structure}_api size)"
    echo "  Пуст: $(${structure}_api is_empty)"
    echo "  Содержимое:"
    ${structure}_api display
}

# Проверка всех структур
check_structure_status "stack"
check_structure_status "queue" 
check_structure_status "priority_queue"
```

## 🚀 Следующие шаги

### 1. Изучите дополнительные примеры
```bash
# Просмотрите все примеры
ls examples/basic_usage/
ls examples/advanced/

# Запустите интересующие демо
./examples/advanced/expression_evaluator.sh
./examples/advanced/task_scheduler.sh
```

### 2. Запустите тесты
```bash
# Полный набор тестов
make test

# Конкретная структура
./tests/test_stack.sh
./tests/test_priority_queue.sh

# Нагрузочное тестирование  
./tests/stress_test.sh
```

### 3. Изучите API документацию
```bash
# Откройте полную документацию
open docs/API_REFERENCE.md

# Или в терминале
less docs/API_REFERENCE.md
```

### 4. Присоединяйтесь к сообществу
- Читайте [CONTRIBUTING.md](CONTRIBUTING.md)
- Изучайте [ROADMAP.md](ROADMAP.md) 
- Создавайте Issues и Pull Requests

## ❓ Часто задаваемые вопросы

### В: Какую структуру данных выбрать для моей задачи?
**О:** 
- **Стек** - Отмена действий, история, рекурсивные алгоритмы
- **Очередь** - Обработка задач, буферизация, BFS алгоритмы  
- **Приоритетная очередь** - Планировщики задач, обработка с приоритетами
- **Deque** - Скользящие окна, кэши, двусторонние операции
- **Связный список** - Динамические коллекции, частые вставки/удаления

### В: Как обрабатывать большие объемы данных?
**О:** Используйте пакетную обработку и ограничивайте размер структур:
```bash
MAX_QUEUE_SIZE=1000
if [[ $(queue_api size) -ge $MAX_QUEUE_SIZE ]]; then
    process_batch
fi
```

### В: Совместимо ли это с другими shell?
**О:** Проект оптимизирован для Bash 4.0+. Некоторые функции могут работать в Zsh, но полная совместимость гарантируется только для Bash.

---

## 🎉 Поздравляем!

Вы успешно начали работу с Bash Data Structures! Теперь вы можете:

- ✅ Использовать мощные структуры данных в Bash-скриптах
- ✅ Обрабатывать сложные данные эффективно
- ✅ Создавать продвинутые системы на чистом Bash
- ✅ Интегрировать библиотеку в существующие проекты

Для углубленного изучения смотрите [API_REFERENCE.md](API_REFERENCE.md) и примеры в папке `examples/`.

**Удачного кодирования!** 🚀