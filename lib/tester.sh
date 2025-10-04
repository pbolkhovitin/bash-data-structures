#!/bin/bash

# tester.sh - Фреймворк для тестирования Bash Data Structures
# Простая и эффективная система тестирования для bash-скриптов

# Глобальные переменные для отслеживания тестов
TEST_PASSED=0
TEST_FAILED=0
TEST_SKIPPED=0
CURRENT_TEST_GROUP=""
CURRENT_TEST_NAME=""
TEST_INDENT_LEVEL=0
ASSERTION_COUNT=0

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# Функции логирования
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1" >&2
}

log_debug() {
    if [[ "${TEST_DEBUG:-false}" == "true" ]]; then
        echo -e "${DIM}🐛 ${NC}$1"
    fi
}

# Начало тестовой группы
describe() {
    CURRENT_TEST_GROUP="$1"
    TEST_INDENT_LEVEL=0
    ASSERTION_COUNT=0
    
    echo -e "\n${BOLD}${CYAN}🧪 ТЕСТИРОВАНИЕ: $CURRENT_TEST_GROUP${NC}"
    echo -e "${CYAN}════════════════════════════════════${NC}"
}

# Начало конкретного теста
it() {
    CURRENT_TEST_NAME="$1"
    TEST_INDENT_LEVEL=1
    ASSERTION_COUNT=0
    
    echo -ne "${DIM}  • ${CURRENT_TEST_NAME}...${NC} "
}

# Конец тестовой группы
end_describe() {
    local total_tests=$((TEST_PASSED + TEST_FAILED + TEST_SKIPPED))
    local passed_percent=0
    
    if [[ $total_tests -gt 0 ]]; then
        passed_percent=$((TEST_PASSED * 100 / total_tests))
    fi
    
    echo -e "\n${CYAN}════════════════════════════════════${NC}"
    echo -e "${BOLD}📊 РЕЗУЛЬТАТЫ ГРУППЫ:${NC}"
    echo -e "  ${GREEN}✅ Пройдено: $TEST_PASSED${NC}"
    echo -e "  ${RED}❌ Не пройдено: $TEST_FAILED${NC}"
    
    if [[ $TEST_SKIPPED -gt 0 ]]; then
        echo -e "  ${YELLOW}⏭ Пропущено: $TEST_SKIPPED${NC}"
    fi
    
    echo -e "  ${BOLD}📈 Успешность: ${passed_percent}%${NC}"
    
    if [[ $TEST_FAILED -eq 0 ]]; then
        echo -e "\n${BOLD}${GREEN}🎉 Все тесты в группе пройдены успешно!${NC}"
        return 0
    else
        echo -e "\n${BOLD}${RED}💥 Найдены ошибки в тестах${NC}"
        return 1
    fi
}

# Assert функции

assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    ((ASSERTION_COUNT++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_EQUAL: Ожидалось '$expected', Получено '$actual' - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Ожидалось: '$expected'${NC}"
        echo -e "    ${DIM}Получено:  '$actual'${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        echo -e "    ${DIM}Группа: $CURRENT_TEST_GROUP${NC}"
        return 1
    fi
}

assert_not_equal() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-}"
    ((ASSERTION_COUNT++))
    
    if [[ "$unexpected" != "$actual" ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_NOT_EQUAL: Не ожидалось '$unexpected', Получено '$actual' - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Не ожидалось: '$unexpected'${NC}"
        echo -e "    ${DIM}Получено:     '$actual'${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if $condition; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_TRUE: Условие истинно - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Условие ложно: $condition${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if ! $condition; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_FALSE: Условие ложно - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Условие истинно (ожидалось ложь): $condition${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_success() {
    local command="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if eval "$command" >/dev/null 2>&1; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_SUCCESS: Команда '$command' выполнена успешно - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Команда завершилась с ошибкой: $command${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_failure() {
    local command="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if ! eval "$command" >/dev/null 2>&1; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_FAILURE: Команда '$command' завершилась с ошибкой (как и ожидалось) - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Команда завершилась успешно (ожидалась ошибка): $command${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_contains() {
    local container="$1"
    local content="$2"
    local message="${3:-}"
    ((ASSERTION_COUNT++))
    
    if [[ "$container" == *"$content"* ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_CONTAINS: '$container' содержит '$content' - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Контейнер: '$container'${NC}"
        echo -e "    ${DIM}Не содержит: '$content'${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_not_contains() {
    local container="$1"
    local content="$2"
    local message="${3:-}"
    ((ASSERTION_COUNT++))
    
    if [[ "$container" != *"$content"* ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_NOT_CONTAINS: '$container' не содержит '$content' - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Контейнер: '$container'${NC}"
        echo -e "    ${DIM}Содержит (не ожидалось): '$content'${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_empty() {
    local value="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if [[ -z "$value" ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_EMPTY: Значение пусто - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Значение не пусто: '$value'${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-}"
    ((ASSERTION_COUNT++))
    
    if [[ -n "$value" ]]; then
        echo -ne "${GREEN}✅${NC} "
        ((TEST_PASSED++))
        log_debug "ASSERT_NOT_EMPTY: Значение не пусто - ПРОЙДЕНО"
        return 0
    else
        echo -ne "${RED}❌${NC} "
        ((TEST_FAILED++))
        echo -e "\n${RED}    Ошибка в тесте: ${CURRENT_TEST_NAME}${NC}"
        echo -e "    ${DIM}Значение пусто (ожидалось не пустое)${NC}"
        if [[ -n "$message" ]]; then
            echo -e "    ${DIM}Сообщение: $message${NC}"
        fi
        return 1
    fi
}

# Функции для пропуска тестов
skip() {
    local reason="${1:-без указания причины}"
    ((TEST_SKIPPED++))
    echo -ne "${YELLOW}⏭${NC} "
    echo -e "${DIM}(Пропущено: $reason)${NC}"
}

skip_if() {
    local condition="$1"
    local reason="${2:-условие выполнено}"
    
    if $condition; then
        skip "$reason"
        return 0
    fi
    return 1
}

# Функции для управления тестами
run_test() {
    local test_function="$1"
    local test_name="$2"
    
    it "$test_name"
    if $test_function; then
        echo -e "${GREEN}ПРОЙДЕН${NC}"
    else
        echo -e "${RED}НЕ ПРОЙДЕН${NC}"
    fi
}

setup() {
    log_debug "Настройка перед тестом: $CURRENT_TEST_NAME"
    # Может быть переопределена пользователем
}

teardown() {
    log_debug "Очистка после теста: $CURRENT_TEST_NAME"
    # Может быть переопределена пользователем
}

# Запуск теста с таймаутом
run_with_timeout() {
    local timeout_seconds="$1"
    local command="${*:2}"
    
    timeout "$timeout_seconds" bash -c "$command" 2>/dev/null
    local result=$?
    
    if [[ $result -eq 124 ]]; then
        log_error "ТЕСТ ПРЕРВАН: превышен таймаут ${timeout_seconds}с"
        return 1
    elif [[ $result -eq 0 ]]; then
        return 0
    else
        return $result
    fi
}

# Сброс счетчиков тестов
reset_test_counters() {
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_SKIPPED=0
    CURRENT_TEST_GROUP=""
    CURRENT_TEST_NAME=""
    ASSERTION_COUNT=0
}

# Функция для вывода итогов всех тестов
print_test_summary() {
    local total_tests=$((TEST_PASSED + TEST_FAILED + TEST_SKIPPED))
    local passed_percent=0
    
    if [[ $total_tests -gt 0 ]]; then
        passed_percent=$((TEST_PASSED * 100 / total_tests))
    fi
    
    echo -e "\n${BOLD}${PURPLE}🎯 ОБЩИЕ РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ${NC}"
    echo -e "${PURPLE}════════════════════════════════════${NC}"
    echo -e "  ${GREEN}✅ Пройдено: $TEST_PASSED${NC}"
    echo -e "  ${RED}❌ Не пройдено: $TEST_FAILED${NC}"
    
    if [[ $TEST_SKIPPED -gt 0 ]]; then
        echo -e "  ${YELLOW}⏭ Пропущено: $TEST_SKIPPED${NC}"
    fi
    
    echo -e "  ${BOLD}📈 Общая успешность: ${passed_percent}%${NC}"
    echo -e "  ${BOLD}📊 Всего тестов: $total_tests${NC}"
    
    if [[ $TEST_FAILED -eq 0 && $TEST_PASSED -gt 0 ]]; then
        echo -e "\n${BOLD}${GREEN}🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!${NC}"
        return 0
    elif [[ $TEST_FAILED -gt 0 ]]; then
        echo -e "\n${BOLD}${RED}💥 НАЙДЕНЫ ОШИБКИ В ТЕСТАХ${NC}"
        return 1
    else
        echo -e "\n${BOLD}${YELLOW}ℹ НЕТ ЗАПУЩЕННЫХ ТЕСТОВ${NC}"
        return 0
    fi
}

# Функция для создания временных файлов
create_temp_file() {
    local prefix="${1:-test}"
    mktemp "/tmp/${prefix}_XXXXXX"
}

create_temp_dir() {
    local prefix="${1:-test}"
    mktemp -d "/tmp/${prefix}_XXXXXX"
}

# Валидация тестового окружения
validate_test_environment() {
    local errors=0
    
    # Проверка наличия необходимых команд
    local required_commands="bash date echo printf"
    for cmd in $required_commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Не найдена обязательная команда: $cmd"
            ((errors++))
        fi
    done
    
    # Проверка версии bash
    if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
        log_warning "Рекомендуется Bash 4.0+ (текущая версия: ${BASH_VERSION})"
    fi
    
    return $errors
}

# Демонстрация использования фреймворка
demo_test_framework() {
    echo -e "${BOLD}${CYAN}ДЕМОНСТРАЦИЯ ФРЕЙМВОРКА ТЕСТИРОВАНИЯ${NC}"
    
    describe "Демонстрация различных assert функций"
    
    it "assert_equal - сравнение одинаковых значений"
    assert_equal "hello" "hello" "Строки должны быть равны"
    
    it "assert_not_equal - сравнение разных значений"
    assert_not_equal "hello" "world" "Строки должны отличаться"
    
    it "assert_true - проверка истинного условия"
    assert_true "[[ 1 -eq 1 ]]" "1 должно равняться 1"
    
    it "assert_false - проверка ложного условия"
    assert_false "[[ 1 -eq 2 ]]" "1 не должно равняться 2"
    
    it "assert_contains - проверка содержания подстроки"
    assert_contains "hello world" "world" "Должно содержать 'world'"
    
    it "assert_success - успешное выполнение команды"
    assert_success "true" "Команда должна завершиться успешно"
    
    end_describe
}

# Инициализация фреймворка
init_test_framework() {
    log_info "Инициализация фреймворка тестирования"
    validate_test_environment
    
    # Создаем временную директорию для тестов
    export TEST_TEMP_DIR=$(create_temp_dir "test_framework")
    log_debug "Временная директория: $TEST_TEMP_DIR"
    
    # Устанавливаем обработчик для очистки
    trap 'cleanup_test_framework' EXIT
}

# Очистка тестового окружения
cleanup_test_framework() {
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        log_debug "Очистка временной директории: $TEST_TEMP_DIR"
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Экспорт функций для использования в тестах
export -f describe it end_describe
export -f assert_equal assert_not_equal assert_true assert_false
export -f assert_success assert_failure assert_contains assert_not_contains
export -f assert_empty assert_not_empty
export -f skip skip_if run_test
export -f setup teardown run_with_timeout
export -f reset_test_counters print_test_summary
export -f create_temp_file create_temp_dir
export -f log_info log_success log_warning log_error log_debug

# Авто-инициализация при загрузке
if [[ "${TEST_AUTO_INIT:-true}" == "true" ]]; then
    init_test_framework
fi

# Если скрипт запущен напрямую - показать демо
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${BOLD}Bash Data Structures - Test Framework${NC}"
    echo "Использование: source tester.sh"
    echo ""
    echo "Функции:"
    echo "  describe 'group' - начать группу тестов"
    echo "  it 'test'       - начать тест"
    echo "  assert_*        - различные проверки"
    echo "  end_describe    - завершить группу"
    echo ""
    demo_test_framework
fi