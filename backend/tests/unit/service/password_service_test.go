// unit/service/password_service_test.go
package service

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"lissanai.com/backend/internal/service"
)

func TestPasswordService_HashPassword(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "testpassword123"

	// Test
	hashedPassword, err := passwordService.HashPassword(password)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, hashedPassword)
	assert.NotEqual(t, password, hashedPassword)
	assert.Contains(t, hashedPassword, "$2a$") // bcrypt prefix
}

func TestPasswordService_CheckPassword(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "testpassword123"

	// Hash the password
	hashedPassword, err := passwordService.HashPassword(password)
	require.NoError(t, err)

	// Test correct password
	t.Run("CorrectPassword", func(t *testing.T) {
		isValid := passwordService.CheckPassword(password, hashedPassword)
		assert.True(t, isValid)
	})

	// Test incorrect password
	t.Run("IncorrectPassword", func(t *testing.T) {
		isValid := passwordService.CheckPassword("wrongpassword", hashedPassword)
		assert.False(t, isValid)
	})

	// Test empty password
	t.Run("EmptyPassword", func(t *testing.T) {
		isValid := passwordService.CheckPassword("", hashedPassword)
		assert.False(t, isValid)
	})

	// Test empty hash
	t.Run("EmptyHash", func(t *testing.T) {
		isValid := passwordService.CheckPassword(password, "")
		assert.False(t, isValid)
	})
}

func TestPasswordService_HashPassword_EmptyPassword(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()

	// Test
	hashedPassword, err := passwordService.HashPassword("")

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, hashedPassword)
}

func TestPasswordService_HashPassword_SpecialCharacters(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "!@#$%^&*()_+-=[]{}|;':\",./<>?`~"

	// Test
	hashedPassword, err := passwordService.HashPassword(password)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, hashedPassword)

	// Verify the password can be checked
	isValid := passwordService.CheckPassword(password, hashedPassword)
	assert.True(t, isValid)
}

func TestPasswordService_HashPassword_Unicode(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "测试密码123🔐"

	// Test
	hashedPassword, err := passwordService.HashPassword(password)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, hashedPassword)

	// Verify the password can be checked
	isValid := passwordService.CheckPassword(password, hashedPassword)
	assert.True(t, isValid)
}

func TestPasswordService_HashPassword_VeryLongPassword(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	// bcrypt supports up to 72 bytes; keep below that threshold to avoid error in this test
	password := string(bytes.Repeat([]byte("a"), 70))

	// Test
	hashedPassword, err := passwordService.HashPassword(password)

	// Assert
	require.NoError(t, err)
	assert.NotEmpty(t, hashedPassword)

	// Verify the password can be checked
	isValid := passwordService.CheckPassword(password, hashedPassword)
	assert.True(t, isValid)
}

func TestPasswordService_Consistency(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "consistentpassword123"

	// Hash the same password multiple times
	hashes := make([]string, 5)
	for i := 0; i < 5; i++ {
		hash, err := passwordService.HashPassword(password)
		require.NoError(t, err)
		hashes[i] = hash
	}

	// All hashes should be different (due to salt)
	for i := 0; i < len(hashes); i++ {
		for j := i + 1; j < len(hashes); j++ {
			assert.NotEqual(t, hashes[i], hashes[j], "Hashes should be different due to salt")
		}
	}

	// But all should validate the same password
	for _, hash := range hashes {
		isValid := passwordService.CheckPassword(password, hash)
		assert.True(t, isValid, "All hashes should validate the same password")
	}
}

func TestPasswordService_InvalidHash(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "testpassword123"
	invalidHash := "invalidhash"

	// Test
	isValid := passwordService.CheckPassword(password, invalidHash)

	// Assert
	assert.False(t, isValid)
}

func TestPasswordService_MalformedHash(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "testpassword123"
	malformedHash := "$2a$10$invalid"

	// Test
	isValid := passwordService.CheckPassword(password, malformedHash)

	// Assert
	assert.False(t, isValid)
}

func TestPasswordService_ConcurrentAccess(t *testing.T) {
	// Setup
	passwordService := service.NewPasswordService()
	password := "concurrentpassword123"

	// Test concurrent hashing
	done := make(chan bool, 10)

	for i := 0; i < 10; i++ {
		go func() {
			defer func() { done <- true }()

			hash, err := passwordService.HashPassword(password)
			assert.NoError(t, err)
			assert.NotEmpty(t, hash)

			isValid := passwordService.CheckPassword(password, hash)
			assert.True(t, isValid)
		}()
	}

	// Wait for all goroutines to complete
	for i := 0; i < 10; i++ {
		<-done
	}
}
