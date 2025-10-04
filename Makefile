.PHONY: test unit-test stress-test perf-test

# Запуск всех тестов
test: unit-test stress-test perf-test

# Модульные тесты
unit-test:
	@echo "🧪 Запуск модульных тестов..."
	@for test_file in tests/test_*.sh; do \
		echo "Выполнение $$test_file..."; \
		bash "$$test_file" || exit 1; \
	done

# Нагрузочные тесты  
stress-test:
	@echo "🔥 Запуск нагрузочных тестов..."
	@bash tests/stress_test.sh

# Тесты производительности
perf-test:
	@echo "⚡ Запуск тестов производительности..."
	@bash tests/performance_test.sh