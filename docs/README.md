markdown
# Bash Data Structures 🚀

![Bash Version](https://img.shields.io/badge/Bash-4.0%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)

**Профессиональная коллекция структур данных, реализованных на чистом Bash.** Идеально для системного администрирования, DevOps задач и встраивания в shell-скрипты.

## 🌟 Особенности

- **💯 Чистый Bash** - Без внешних зависимостей, только нативные команды
- **🏗️ Production-ready** - Логирование, обработка ошибок, комплексное тестирование
- **🔧 Двойной интерфейс** - Интерактивный режим + API для скриптов
- **📦 Модульная архитектура** - Легко расширяется и интегрируется
- **⚡ Высокая производительность** - Оптимизированные алгоритмы
- **📚 Полная документация** - Примеры, тесты, бенчмарки

## 🏗️ Структуры данных

### ✅ Реализовано

| Структура | Файл | Сложность | Особенности |
|-----------|------|-----------|-------------|
| **Стек (LIFO)** | `src/stack.sh` | O(1) | Push/pop/peek, поиск, отображение |
| **Очередь (FIFO)** | `src/queue.sh` | O(1) | Enqueue/dequeue, циклический буфер |
| **Двусторонняя очередь** | `src/deque.sh` | O(1) | Добавление/удаление с обоих концов |
| **Приоритетная очередь** | `src/priority_queue.sh` | O(n) insert | Элементы с высшим приоритетом первыми |
| **Связный список** | `src/linked_list.sh` | O(n) access | Динамическое выделение памяти |

### 🔄 В планах

- Хэш-таблица (Hash Table)
- Бинарное дерево (Binary Tree)
- Куча (Heap)
- Граф (Graph)

## 🚀 Быстрый старт

### Установка

```bash
# Клонирование репозитория
git clone https://github.com/your-username/bash-data-structures.git
cd bash-data-structures

# Установка (делает скрипты исполняемыми)
make install
Базовое использование
Стек (LIFO)
bash
source src/stack.sh

stack_api init
stack_api push "Hello"
stack_api push "World"
echo "Размер: $(stack_api size)"        # 2
echo "Верхний: $(stack_api peek)"       # World
echo "Извлечен: $(stack_api pop)"       # World
Очередь (FIFO)
bash
source src/queue.sh

queue_api init
queue_api enqueue "First"
queue_api enqueue "Second"
echo "Размер: $(queue_api size)"        # 2
echo "Обработан: $(queue_api dequeue)"  # First
Приоритетная очередь
bash
source src/priority_queue.sh

priority_queue_api init
priority_queue_api enqueue "Обычная" 5
priority_queue_api enqueue "Срочная" 1
echo "Следующая: $(priority_queue_api dequeue)"  # Срочная
Интерактивный режим
bash
# Запуск демо
./examples/basic_usage/stack_demo.sh
./examples/basic_usage/queue_demo.sh
./examples/basic_usage/priority_queue_demo.sh

# Интерактивные примеры
./examples/advanced/expression_evaluator.sh
🧪 Тестирование
bash
# Запуск всех тестов
make test

# Тестирование конкретной структуры
./tests/test_stack.sh
./tests/test_queue.sh
./tests/test_deque.sh
./tests/test_priority_queue.sh
./tests/test_linked_list.sh

# Нагрузочное тестирование
./tests/stress_test.sh
📊 Бенчмарки
bash
# Сравнение производительности
make bench

# Запуск отдельных бенчмарков
./benchmarks/compare_implementations.sh
./benchmarks/memory_usage_test.sh
🏗️ Архитектура
text
bash-data-structures/
├── 📁 src/                    # Реализации структур данных
├── 📁 lib/                   # Общие библиотеки
│   ├── logger.sh            # Система логирования
│   ├── tester.sh            # Фреймворк тестирования
│   ├── formatter.sh         # Форматирование вывода
│   └── validator.sh         # Валидация данных
├── 📁 examples/             # Примеры использования
├── 📁 tests/                # Комплексные тесты
├── 📁 docs/                 # Документация
└── 📁 benchmarks/           # Тесты производительности
🔧 Интеграция в ваши проекты
Как отдельная библиотека
bash
# В вашем скрипте
source /path/to/bash-data-structures/src/stack.sh
source /path/to/bash-data-structures/lib/logger.sh

# Использование
stack_api push "данные"
Как подмодуль Git
bash
git submodule add https://github.com/your-username/bash-data-structures.git lib/bash-ds

# В вашем скрипте
source lib/bash-ds/src/queue.sh
🤝 Участие в разработке
Мы приветствуем contributions!

Форкните репозиторий

Создайте ветку для функции: git checkout -b feature/amazing-feature

Закоммитьте изменения: git commit -m 'Add amazing feature'

Запушьте ветку: git push origin feature/amazing-feature

Откройте Pull Request

Подробнее в CONTRIBUTING.md

📝 Требования
Bash 4.0+ (рекомендуется 4.4+ для лучшей производительности)

GNU Coreutils (стандартно в большинстве Linux-систем)

POSIX-совместимая среда

🐛 Сообщение об ошибках
Нашли баг? Создайте issue с подробным описанием:

Версия Bash и ОС

Шаги для воспроизведения

Ожидаемое поведение

Фактическое поведение

📄 Лицензия
Этот проект лицензирован под MIT License - см. LICENSE.

🙏 Благодарности
Спасибо всем контрибьюторам, которые помогают развивать проект!