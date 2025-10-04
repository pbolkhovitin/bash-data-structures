#!/bin/bash

# logger.sh - Унифицированная система логирования для Bash Data Structures

# Используем временную директорию по умолчанию, если системная недоступна
DEFAULT_LOG_DIR="/tmp/bash-ds-logs"
SYSTEM_LOG_DIR="/var/log/bash-ds"

# Пробуем использовать системную директорию, если доступна
if [[ -w "$SYSTEM_LOG_DIR" ]] || mkdir -p "$SYSTEM_LOG_DIR" 2>/dev/null; then
    readonly LOG_DIR="${LOG_DIR:-$SYSTEM_LOG_DIR}"
else
    readonly LOG_DIR="${LOG_DIR:-$DEFAULT_LOG_DIR}"
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        echo "Warning: Cannot create log directory $LOG_DIR" >&2
    }
fi

readonly MAX_LOG_SIZE=${MAX_LOG_SIZE:-1048576}  # 1MB
readonly MAX_LOG_FILES=${MAX_LOG_FILES:-5}

# Уровни логирования
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3

# Текущий уровень логирования (по умолчанию INFO)
CURRENT_LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Инициализация системы логирования
logger::init() {
    local component="${1:-general}"
    local log_level="${2:-$CURRENT_LOG_LEVEL}"
    
    CURRENT_LOG_LEVEL=$log_level
    
    # Создаем директорию логов если нужно
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            echo "Warning: Cannot create log directory $LOG_DIR" >&2
            return 1
        }
    fi
    
    export LOG_FILE="$LOG_DIR/${component}.log"
    logger::info "Logger initialized for component: $component (level: $log_level)"
    return 0
}

# Ротация логов
logger::rotate() {
    local log_file="${1:-$LOG_FILE}"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    local file_size=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null)
    
    if [[ $file_size -gt $MAX_LOG_SIZE ]]; then
        local timestamp=$(date '+%Y%m%d_%H%M%S')
        local rotated_file="${log_file}.${timestamp}"
        
        mv "$log_file" "$rotated_file" 2>/dev/null
        
        # Удаляем старые логи
        find "$(dirname "$log_file")" -name "$(basename "$log_file").*" -type f \
             -mtime +$MAX_LOG_FILES -delete 2>/dev/null
    fi
}

# Базовая функция логирования
logger::log() {
    local level="$1"
    local message="$2"
    local component="${3:-${COMPONENT:-unknown}}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$component] [$level] $message"
    
    # Ротация перед записью
    logger::rotate
    
    # Записываем в файл
    if [[ -n "$LOG_FILE" && -w "$(dirname "$LOG_FILE")" ]]; then
        echo "$log_entry" >> "$LOG_FILE"
    fi
    
    # Выводим в консоль в зависимости от уровня
    case "$level" in
        "DEBUG")
            if [[ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
                echo -e "${BLUE}🐛 $log_entry${NC}" >&2
            fi
            ;;
        "INFO")
            if [[ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_INFO ]]; then
                echo -e "${GREEN}ℹ $log_entry${NC}" >&2
            fi
            ;;
        "WARNING")
            if [[ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_WARNING ]]; then
                echo -e "${YELLOW}⚠ $log_entry${NC}" >&2
            fi
            ;;
        "ERROR")
            if [[ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_ERROR ]]; then
                echo -e "${RED}✗ $log_entry${NC}" >&2
            fi
            ;;
    esac
}

# Функции для разных уровней логирования
logger::debug() {
    logger::log "DEBUG" "$1" "$2"
}

logger::info() {
    logger::log "INFO" "$1" "$2"
}

logger::warning() {
    logger::log "WARNING" "$1" "$2"
}

logger::error() {
    logger::log "ERROR" "$1" "$2"
}

# Установка уровня логирования
logger::set_level() {
    case "$1" in
        "DEBUG") CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        "INFO") CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO ;;
        "WARNING") CURRENT_LOG_LEVEL=$LOG_LEVEL_WARNING ;;
        "ERROR") CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        *) logger::error "Unknown log level: $1" ;;
    esac
}

# Получение текущего уровня логирования
logger::get_level() {
    case "$CURRENT_LOG_LEVEL" in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO) echo "INFO" ;;
        $LOG_LEVEL_WARNING) echo "WARNING" ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
    esac
}

# Экспорт функций
export -f logger::init logger::rotate logger::log
export -f logger::debug logger::info logger::warning logger::error
export -f logger::set_level logger::get_level