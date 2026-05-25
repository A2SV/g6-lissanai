// unit/service/jwt_service_test.go
package service

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/service"
)

func TestJWTService_GenerateAccessToken(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")
	userID := primitive.NewObjectID()

	// Test
	token, err := jwtService.GenerateAccessToken(userID)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, token)
	assert.Contains(t, token, ".")
}

func TestJWTService_GenerateRefreshToken(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")

	// Test
	token, err := jwtService.GenerateRefreshToken()

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, token)
	assert.Contains(t, token, ".")
}

func TestJWTService_ValidateAccessToken(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")
	userID := primitive.NewObjectID()

	// Generate a valid token
	validToken, err := jwtService.GenerateAccessToken(userID)
	require.NoError(t, err)

	// Test valid token
	t.Run("ValidToken", func(t *testing.T) {
		token, err := jwtService.ValidateAccessToken(validToken)

		require.NoError(t, err)
		assert.True(t, token.Valid)
	})

	// Test invalid token
	t.Run("InvalidToken", func(t *testing.T) {
		_, err := jwtService.ValidateAccessToken("invalid.token.here")

		assert.Error(t, err)
	})

	// Test empty token
	t.Run("EmptyToken", func(t *testing.T) {
		_, err := jwtService.ValidateAccessToken("")

		assert.Error(t, err)
	})
}

func TestJWTService_ExtractUserID(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")
	userID := primitive.NewObjectID()

	// Generate a valid token
	validToken, err := jwtService.GenerateAccessToken(userID)
	require.NoError(t, err)

	// Validate the token
	token, err := jwtService.ValidateAccessToken(validToken)
	require.NoError(t, err)

	// Test
	extractedUserID, err := jwtService.ExtractUserID(token)

	// Assert
	require.NoError(t, err)
	assert.Equal(t, userID, extractedUserID)
}

func TestJWTService_ExtractUserID_InvalidToken(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")

	// Create an invalid token
	invalidToken := &jwt.Token{
		Valid:  false,
		Claims: nil,
	}

	// Test
	_, err := jwtService.ExtractUserID(invalidToken)

	// Assert
	assert.Error(t, err)
}

func TestJWTService_TokenExpiration(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")
	userID := primitive.NewObjectID()

	// Test
	token, err := jwtService.GenerateAccessToken(userID)
	require.NoError(t, err)

	// Validate token
	validatedToken, err := jwtService.ValidateAccessToken(token)
	require.NoError(t, err)

	// Check expiration
	claims, ok := validatedToken.Claims.(*service.Claims)
	require.True(t, ok)

	// Token should expire in the future
	assert.True(t, claims.ExpiresAt.Time.After(time.Now()))
}

func TestJWTService_DifferentSecrets(t *testing.T) {
	// Setup
	jwtService1 := service.NewJWTService("secret1")
	jwtService2 := service.NewJWTService("secret2")
	userID := primitive.NewObjectID()

	// Generate token with first service
	token, err := jwtService1.GenerateAccessToken(userID)
	require.NoError(t, err)

	// Try to validate with second service (should fail)
	_, err = jwtService2.ValidateAccessToken(token)
	assert.Error(t, err)
}

func TestJWTService_EmptySecret(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("")
	userID := primitive.NewObjectID()

	// Test
	token, err := jwtService.GenerateAccessToken(userID)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, token)
}

func TestJWTService_ConcurrentAccess(t *testing.T) {
	// Setup
	jwtService := service.NewJWTService("test-secret-key")
	userID := primitive.NewObjectID()

	// Test concurrent token generation
	done := make(chan bool, 10)

	for i := 0; i < 10; i++ {
		go func() {
			defer func() { done <- true }()

			token, err := jwtService.GenerateAccessToken(userID)
			assert.NoError(t, err)
			assert.NotEmpty(t, token)
		}()
	}

	// Wait for all goroutines to complete
	for i := 0; i < 10; i++ {
		<-done
	}
}
