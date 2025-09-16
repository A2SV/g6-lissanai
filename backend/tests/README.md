# Backend Testing Suite

This directory contains comprehensive tests for the LissanAI backend API.

## Test Structure

```
tests/
├── README.md                 # This file
├── config/                   # Test configuration
│   ├── test_config.go       # Test environment setup
│   └── test_data.go         # Test data fixtures
├── mocks/                   # Mock implementations
│   ├── repository_mocks.go  # Repository mocks
│   ├── service_mocks.go     # Service mocks
│   └── client_mocks.go      # External client mocks
├── utils/                   # Test utilities
│   ├── test_helpers.go      # Common test helpers
│   ├── db_helpers.go        # Database test helpers
│   └── auth_helpers.go      # Authentication test helpers
├── unit/                    # Unit tests
│   ├── service/             # Service layer tests
│   ├── usecase/             # Use case layer tests
│   ├── handler/             # Handler layer tests
│   └── repository/          # Repository layer tests
├── integration/             # Integration tests
│   ├── api/                 # API endpoint tests
│   ├── database/            # Database integration tests
│   └── external/            # External service integration tests
└── e2e/                     # End-to-end tests
    ├── auth_flow_test.go    # Complete auth flow tests
    ├── learning_flow_test.go # Learning system tests
    └── streak_flow_test.go  # Streak system tests
```

## Running Tests

### All Tests
```bash
go test ./tests/...
```

### Unit Tests Only
```bash
go test ./tests/unit/...
```

### Integration Tests Only
```bash
go test ./tests/integration/...
```

### E2E Tests Only
```bash
go test ./tests/e2e/...
```

### Specific Test Package
```bash
go test ./tests/unit/service/
```

### With Coverage
```bash
go test -cover ./tests/...
go test -coverprofile=coverage.out ./tests/...
go tool cover -html=coverage.out
```

### With Verbose Output
```bash
go test -v ./tests/...
```

## Test Environment Setup

1. **Test Database**: Uses a separate test database (`lissanai_test`)
2. **Environment Variables**: Loaded from `tests/.env.test`
3. **Mock Services**: External services are mocked by default
4. **Test Data**: Predefined test fixtures for consistent testing

## Test Categories

### Unit Tests
- **Services**: JWT, password, email, AI services
- **Use Cases**: Business logic validation
- **Handlers**: HTTP request/response handling
- **Repositories**: Data access layer

### Integration Tests
- **API Endpoints**: Full request/response cycles
- **Database Operations**: Real database interactions
- **External Services**: Actual external API calls (optional)

### E2E Tests
- **User Flows**: Complete user journeys
- **Authentication**: Login, registration, password reset
- **Learning System**: Path enrollment, lesson completion
- **Streak System**: Activity tracking, streak management

## Test Data Management

- **Fixtures**: Predefined test data in `config/test_data.go`
- **Cleanup**: Automatic cleanup after each test
- **Isolation**: Each test runs in isolation
- **Seeding**: Database seeded with test data before tests

## Mocking Strategy

- **External APIs**: All external services are mocked by default
- **Database**: Real database for integration tests, mocked for unit tests
- **Time**: Time-dependent tests use fixed timestamps
- **Random**: Deterministic random values for consistent tests

## Coverage Goals

- **Unit Tests**: >90% code coverage
- **Integration Tests**: >80% API endpoint coverage
- **E2E Tests**: Critical user flows covered

## Continuous Integration

Tests are designed to run in CI/CD pipelines:
- No external dependencies required
- Deterministic test results
- Fast execution (< 5 minutes for full suite)
- Clear failure reporting
