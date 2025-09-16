// unit/usecase/auth_usecase_test.go
package usecase

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
	"lissanai.com/backend/tests/mocks"
)

func TestAuthUsecase_Register(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	registerRequest := &domain.RegisterRequest{
		Name:     "Test User",
		Email:    "test@example.com",
		Password: "password123",
	}

	// Test
	response, err := authUsecase.Register(registerRequest)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.NotNil(t, response.User)
	assert.Equal(t, "Test User", response.User.Name)
	assert.Equal(t, "test@example.com", response.User.Email)
	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
	assert.Equal(t, int64(15*60), response.ExpiresIn)

	// Verify user was created in repository
	createdUser, err := userRepo.GetUserByEmail("test@example.com")
	require.NoError(t, err)
	assert.Equal(t, "Test User", createdUser.Name)
	assert.Equal(t, "test@example.com", createdUser.Email)
	assert.NotEmpty(t, createdUser.PasswordHash)
}

func TestAuthUsecase_Register_DuplicateEmail(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	// Create first user
	firstRequest := &domain.RegisterRequest{
		Name:     "First User",
		Email:    "test@example.com",
		Password: "password123",
	}
	_, err := authUsecase.Register(firstRequest)
	require.NoError(t, err)

	// Try to create second user with same email
	secondRequest := &domain.RegisterRequest{
		Name:     "Second User",
		Email:    "test@example.com",
		Password: "password456",
	}

	// Test
	response, err := authUsecase.Register(secondRequest)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "user with this email already exists")
}

func TestAuthUsecase_Login(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	// Create a user first
	registerRequest := &domain.RegisterRequest{
		Name:     "Test User",
		Email:    "test@example.com",
		Password: "password123",
	}
	_, err := authUsecase.Register(registerRequest)
	require.NoError(t, err)

	loginRequest := &domain.LoginRequest{
		Email:    "test@example.com",
		Password: "password123",
	}

	// Test
	response, err := authUsecase.Login(loginRequest)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.NotNil(t, response.User)
	assert.Equal(t, "test@example.com", response.User.Email)
	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
}

func TestAuthUsecase_Login_InvalidCredentials(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	loginRequest := &domain.LoginRequest{
		Email:    "nonexistent@example.com",
		Password: "password123",
	}

	// Test
	response, err := authUsecase.Login(loginRequest)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "invalid email or password")
}

func TestAuthUsecase_Login_WrongPassword(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	// Create a user first
	registerRequest := &domain.RegisterRequest{
		Name:     "Test User",
		Email:    "test@example.com",
		Password: "password123",
	}
	_, err := authUsecase.Register(registerRequest)
	require.NoError(t, err)

	loginRequest := &domain.LoginRequest{
		Email:    "test@example.com",
		Password: "wrongpassword",
	}

	// Test
	response, err := authUsecase.Login(loginRequest)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "invalid email or password")
}

func TestAuthUsecase_SocialAuth_NewUser(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	socialRequest := &domain.SocialAuthRequest{
		Provider:    "google",
		AccessToken: "google_access_token_123",
		Name:        "Google User",
		Email:       "google@example.com",
	}

	// Test
	response, err := authUsecase.SocialAuth(socialRequest)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.NotNil(t, response.User)
	assert.Equal(t, "Google User", response.User.Name)
	assert.Equal(t, "google@example.com", response.User.Email)
	assert.Equal(t, "google", response.User.Provider)
	assert.Equal(t, "google_access_token_123", response.User.ProviderID)
	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
}

func TestAuthUsecase_SocialAuth_ExistingUser(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	// Create a user first
	registerRequest := &domain.RegisterRequest{
		Name:     "Existing User",
		Email:    "existing@example.com",
		Password: "password123",
	}
	_, err := authUsecase.Register(registerRequest)
	require.NoError(t, err)

	socialRequest := &domain.SocialAuthRequest{
		Provider:    "google",
		AccessToken: "google_access_token_456",
		Name:        "Existing User",
		Email:       "existing@example.com",
	}

	// Test
	response, err := authUsecase.SocialAuth(socialRequest)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.NotNil(t, response.User)
	assert.Equal(t, "existing@example.com", response.User.Email)
	assert.Equal(t, "google", response.User.Provider)
	assert.Equal(t, "google_access_token_456", response.User.ProviderID)
}

func TestAuthUsecase_SocialAuth_NoEmail(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	socialRequest := &domain.SocialAuthRequest{
		Provider:    "google",
		AccessToken: "google_access_token_123",
		Name:        "No Email User",
		Email:       "",
	}

	// Test
	response, err := authUsecase.SocialAuth(socialRequest)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "email is required")
}

func TestAuthUsecase_RefreshToken(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	// Create a user and get refresh token
	registerRequest := &domain.RegisterRequest{
		Name:     "Test User",
		Email:    "test@example.com",
		Password: "password123",
	}
	authResponse, err := authUsecase.Register(registerRequest)
	require.NoError(t, err)

	refreshRequest := &domain.RefreshTokenRequest{
		RefreshToken: authResponse.RefreshToken,
	}

	// Test
	response, err := authUsecase.RefreshToken(refreshRequest)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.NotEmpty(t, response.AccessToken)
	assert.Equal(t, int64(15*60), response.ExpiresIn)
}

func TestAuthUsecase_RefreshToken_InvalidToken(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	refreshRequest := &domain.RefreshTokenRequest{
		RefreshToken: "invalid_refresh_token",
	}

	// Test
	response, err := authUsecase.RefreshToken(refreshRequest)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "invalid refresh token")
}

func TestAuthUsecase_Logout(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	userID := primitive.NewObjectID()
	refreshToken := "test_refresh_token"

	// Create a refresh token
	refreshTokenObj := &domain.RefreshToken{
		UserID:    userID,
		Token:     refreshToken,
		ExpiresAt: time.Now().Add(7 * 24 * time.Hour),
	}
	err := refreshTokenRepo.CreateRefreshToken(refreshTokenObj)
	require.NoError(t, err)

	// Test
	err = authUsecase.Logout(userID, refreshToken)

	// Assert
	require.NoError(t, err)

	// Verify refresh token was deleted
	_, err = refreshTokenRepo.GetRefreshToken(refreshToken)
	assert.Error(t, err)
}

func TestAuthUsecase_Logout_NoRefreshToken(t *testing.T) {
	// Setup
	userRepo := mocks.NewMockUserRepository()
	refreshTokenRepo := mocks.NewMockRefreshTokenRepository()
	passwordResetRepo := mocks.NewMockPasswordResetRepository()
	jwtService := service.NewJWTService("test-secret")
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)

	userID := primitive.NewObjectID()

	// Test
	err := authUsecase.Logout(userID, "")

	// Assert
	require.NoError(t, err)
}
