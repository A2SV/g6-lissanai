# Makefile for LissanAI Backend

.PHONY: build run test clean docs help

# Build the application
build:
	go build -o bin/lissanai-api cmd/api/main.go

# Run the application
run:
	go run cmd/api/main.go

# Run tests
test:
	go test -v ./...

# Clean build artifacts
clean:
	rm -rf bin/
	rm -rf docs/

# Generate Swagger documentation
docs:
	go run github.com/swaggo/swag/cmd/swag@latest init -g cmd/api/main.go

# Install dependencies
deps:
	go mod tidy
	go mod download

# Format code
fmt:
	go fmt ./...

# Lint code (requires golangci-lint)
lint:
	golangci-lint run

# Run with live reload (requires air)
dev:
	air

# Docker build
docker-build:
	docker build -t lissanai-backend .

# Docker run
docker-run:
	docker run -p 8080:8080 --env-file .env lissanai-backend

# Help
help:
	@echo "Available commands:"
	@echo "  build       - Build the application"
	@echo "  run         - Run the application"
	@echo "  test        - Run tests"
	@echo "  clean       - Clean build artifacts"
	@echo "  docs        - Generate Swagger documentation"
	@echo "  deps        - Install dependencies"
	@echo "  fmt         - Format code"
	@echo "  lint        - Lint code"
	@echo "  dev         - Run with live reload"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run  - Run Docker container"
	@echo "  help        - Show this help message"