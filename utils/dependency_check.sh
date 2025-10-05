#!/bin/bash
# dependency_check.sh - Проверка зависимостей для проекта

set -e

echo "🔍 Checking project dependencies..."

# Проверка версии Bash
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "❌ Error: Bash 4.0+ required (current: ${BASH_VERSION})"
    exit 1
fi

# Проверка необходимых команд
required_commands=("bash" "find" "chmod" "mkdir" "echo")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Проверка структуры проекта
required_dirs=("src" "lib" "tests" "examples")
for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
        echo "❌ Error: Required directory '$dir' not found"
        exit 1
    fi
done

# Проверка основных файлов
required_files=("src/stack.sh" "lib/logger.sh" "lib/tester.sh")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Error: Required file '$file' not found"
        exit 1
    fi
done

echo "✅ All dependencies satisfied"