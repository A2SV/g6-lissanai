# Test Makefile for LissanAI Backend

.PHONY: help test test-unit test-integration test-e2e test-coverage test-watch clean setup

# Default target
help:
	@echo "Available targets:"
	@echo "  setup          - Install test dependencies"
	@echo "  test           - Run all tests"
	@echo "  test-unit      - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-e2e       - Run E2E tests only"
	@echo "  test-coverage  - Run tests with coverage report"
	@echo "  test-watch     - Run tests in watch mode"
	@echo "  clean          - Clean test artifacts"

# Install test dependencies
setup:
	@echo "Installing test dependencies..."
	go mod download
	go install github.com/stretchr/testify@latest
	@echo "Test dependencies installed successfully!"

# Run all tests
test:
	@echo "Running all tests..."
	go test -v ./...

# Run unit tests only
test-unit:
	@echo "Running unit tests..."
	go test -v ./unit/...

# Run integration tests only
test-integration:
	@echo "Running integration tests..."
	INTEGRATION_TESTS=true go test -v ./integration/...

# Run E2E tests only
test-e2e:
	@echo "Running E2E tests..."
	E2E_TESTS=true go test -v ./e2e/...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests in watch mode (requires entr)
test-watch:
	@echo "Running tests in watch mode..."
	@if command -v entr >/dev/null 2>&1; then \
		find . -name "*.go" | entr -c make test; \
	else \
		echo "entr not found. Install it to use watch mode."; \
		echo "On macOS: brew install entr"; \
		echo "On Ubuntu: sudo apt-get install entr"; \
	fi

# Run specific test package
test-package:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "Usage: make test-package PACKAGE=./unit/service"; \
		exit 1; \
	fi
	@echo "Running tests for package: $(PACKAGE)"
	go test -v $(PACKAGE)

# Run tests with race detection
test-race:
	@echo "Running tests with race detection..."
	go test -race -v ./...

# Run tests with timeout
test-timeout:
	@echo "Running tests with 30s timeout..."
	go test -timeout 30s -v ./...

# Run tests with verbose output
test-verbose:
	@echo "Running tests with verbose output..."
	go test -v -count=1 ./...

# Run tests and generate JSON report
test-json:
	@echo "Running tests with JSON output..."
	go test -json ./... > test-results.json

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.json
	go clean -testcache
	@echo "Test artifacts cleaned!"

# Run tests for specific functionality
test-auth:
	@echo "Running auth-related tests..."
	go test -v ./unit/usecase/auth_usecase_test.go ./integration/api/auth_integration_test.go ./e2e/auth_flow_test.go

test-services:
	@echo "Running service tests..."
	go test -v ./unit/service/...

test-handlers:
	@echo "Running handler tests..."
	go test -v ./unit/handler/...

# Run tests with different database configurations
test-mongodb:
	@echo "Running tests with MongoDB..."
	MONGODB_URI=mongodb://localhost:27017 MONGODB_DATABASE=lissanai_test go test -v ./integration/...

# Run tests with different JWT secrets
test-jwt:
	@echo "Running tests with custom JWT secret..."
	JWT_SECRET=custom-test-secret go test -v ./unit/service/jwt_service_test.go

# Run performance tests
test-bench:
	@echo "Running benchmark tests..."
	go test -bench=. -benchmem ./...

# Run tests with memory profiling
test-memprofile:
	@echo "Running tests with memory profiling..."
	go test -memprofile=mem.prof ./...
	go tool pprof mem.prof

# Run tests with CPU profiling
test-cpuprofile:
	@echo "Running tests with CPU profiling..."
	go test -cpuprofile=cpu.prof ./...
	go tool pprof cpu.prof

# Run tests in parallel
test-parallel:
	@echo "Running tests in parallel..."
	go test -parallel 4 -v ./...

# Run tests with specific tags
test-tags:
	@echo "Running tests with specific tags..."
	go test -tags=integration -v ./...

# Run tests and show test output
test-show:
	@echo "Running tests with output..."
	go test -v -count=1 ./... | tee test-output.log

# Run tests and fail fast
test-failfast:
	@echo "Running tests with fail fast..."
	go test -failfast -v ./...

# Run tests with short flag
test-short:
	@echo "Running short tests..."
	go test -short -v ./...

# Run tests with verbose and count
test-verbose-count:
	@echo "Running tests with verbose and count..."
	go test -v -count=1 -short ./...

# Run tests and generate JUnit XML report
test-junit:
	@echo "Running tests with JUnit XML output..."
	go test -v ./... | go-junit-report > test-results.xml

# Run tests with different Go versions (if available)
test-go-versions:
	@echo "Running tests with different Go versions..."
	@if command -v go1.23 >/dev/null 2>&1; then \
		echo "Testing with Go 1.23..."; \
		go1.23 test -v ./...; \
	fi
	@if command -v go1.24 >/dev/null 2>&1; then \
		echo "Testing with Go 1.24..."; \
		go1.24 test -v ./...; \
	fi

# Run tests with different architectures
test-arch:
	@echo "Running tests with different architectures..."
	GOOS=linux GOARCH=amd64 go test -v ./...
	GOOS=windows GOARCH=amd64 go test -v ./...
	GOOS=darwin GOARCH=amd64 go test -v ./...

# Run tests with different build tags
test-build-tags:
	@echo "Running tests with different build tags..."
	go test -tags=unit -v ./...
	go test -tags=integration -v ./...
	go test -tags=e2e -v ./...

# Run tests and generate coverage badge
test-coverage-badge:
	@echo "Running tests and generating coverage badge..."
	go test -coverprofile=coverage.out ./...
	coverage=$$(go tool cover -func=coverage.out | tail -1 | awk '{print $$3}' | sed 's/%//'); \
	echo "Coverage: $$coverage%"; \
	if [ $$coverage -ge 80 ]; then \
		echo "✅ Coverage is good ($$coverage%)"; \
	else \
		echo "❌ Coverage is low ($$coverage%)"; \
	fi

# Run tests and check for leaks
test-leaks:
	@echo "Running tests with leak detection..."
	go test -race -v ./... | grep -E "(leak|race)"

# Run tests and measure performance
test-perf:
	@echo "Running performance tests..."
	go test -bench=. -benchmem -cpuprofile=cpu.prof -memprofile=mem.prof ./...

# Run tests with custom timeout per test
test-timeout-custom:
	@echo "Running tests with custom timeout..."
	go test -timeout 60s -v ./...

# Run tests and generate HTML coverage report
test-coverage-html:
	@echo "Running tests with HTML coverage report..."
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

# Run tests and open coverage report
test-coverage-open:
	@echo "Running tests and opening coverage report..."
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@if command -v open >/dev/null 2>&1; then \
		open coverage.html; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open coverage.html; \
	else \
		echo "Please open coverage.html manually"; \
	fi
