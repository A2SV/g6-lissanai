// config/test_config.go
package config

import (
	"log"
	"os"
	"testing"

	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/database"
)

// TestConfig holds configuration for tests
type TestConfig struct {
	MongoDBURI      string
	MongoDBDatabase string
	JWTSecret       string
	TestDB          *mongo.Database
}

var testConfig *TestConfig

// GetTestConfig returns the test configuration
func GetTestConfig() *TestConfig {
	if testConfig == nil {
		testConfig = &TestConfig{
			MongoDBURI:      getEnvOrDefault("MONGODB_URI", "mongodb://localhost:27017"),
			MongoDBDatabase: getEnvOrDefault("MONGODB_DATABASE", "lissanai_test"),
			JWTSecret:       getEnvOrDefault("JWT_SECRET", "test-secret-key-for-testing-only"),
		}
	}
	return testConfig
}

// SetupTestDB initializes the test database
func SetupTestDB(t *testing.T) *mongo.Database {
	config := GetTestConfig()

	// Set environment variables for database connection
	os.Setenv("MONGODB_URI", config.MongoDBURI)
	os.Setenv("MONGODB_DATABASE", config.MongoDBDatabase)

	db, err := database.NewMongoConnection()
	if err != nil {
		t.Fatalf("Failed to connect to test database: %v", err)
	}

	config.TestDB = db
	return db
}

// CleanupTestDB cleans up test data
func CleanupTestDB(t *testing.T, db *mongo.Database) {
	if db == nil {
		return
	}

	// Drop all collections in test database
	collections := []string{
		"users",
		"refresh_tokens",
		"password_resets",
		"learning_paths",
		"lessons",
		"quizzes",
		"user_progress",
		"quiz_submissions",
		"streak_activities",
		"daily_activity_summaries",
		"chat_sessions",
		"chat_messages",
		"pronunciation_activities",
		"email_drafts",
	}

	for _, collection := range collections {
		if err := db.Collection(collection).Drop(nil); err != nil {
			log.Printf("Warning: Failed to drop collection %s: %v", collection, err)
		}
	}
}

// SetupTestEnvironment sets up the test environment
func SetupTestEnvironment(t *testing.T) *TestConfig {
	// Set test environment variables
	os.Setenv("JWT_SECRET", "test-secret-key-for-testing-only")
	os.Setenv("GEMINI_API_KEY", "test-gemini-key")
	os.Setenv("GROQ_API_KEY", "test-groq-key")
	os.Setenv("HF_API_KEY", "test-hf-key")
	os.Setenv("UNREAL_SPEECH_API_KEY", "test-unreal-key")
	os.Setenv("UNREAL_SPEECH_VOICE_ID", "test-voice-id")

	config := GetTestConfig()

	// Setup test database
	config.TestDB = SetupTestDB(t)

	return config
}

// TeardownTestEnvironment cleans up the test environment
func TeardownTestEnvironment(t *testing.T, config *TestConfig) {
	if config != nil && config.TestDB != nil {
		CleanupTestDB(t, config.TestDB)
	}
}

// getEnvOrDefault returns environment variable value or default
func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// IsIntegrationTest checks if we're running integration tests
func IsIntegrationTest() bool {
	return os.Getenv("INTEGRATION_TESTS") == "true"
}

// IsE2ETest checks if we're running E2E tests
func IsE2ETest() bool {
	return os.Getenv("E2E_TESTS") == "true"
}

// SkipIfNotIntegration skips test if not running integration tests
func SkipIfNotIntegration(t *testing.T) {
	if !IsIntegrationTest() {
		t.Skip("Skipping integration test. Set INTEGRATION_TESTS=true to run.")
	}
}

// SkipIfNotE2E skips test if not running E2E tests
func SkipIfNotE2E(t *testing.T) {
	if !IsE2ETest() {
		t.Skip("Skipping E2E test. Set E2E_TESTS=true to run.")
	}
}
