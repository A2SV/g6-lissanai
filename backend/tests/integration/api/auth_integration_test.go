// integration/api/auth_integration_test.go
package api

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/repository"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
	"lissanai.com/backend/tests/config"
	"lissanai.com/backend/tests/mocks"
)

func TestAuthIntegration_Register(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/register", authHandler.Register)

	// Test data
	registerRequest := domain.RegisterRequest{
		Name:     "Integration Test User",
		Email:    "integration@example.com",
		Password: "password123",
	}

	requestBody, err := json.Marshal(registerRequest)
	require.NoError(t, err)

	// Test
	req := httptest.NewRequest("POST", "/auth/register", bytes.NewBuffer(requestBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert
	assert.Equal(t, http.StatusCreated, w.Code)

	var response domain.AuthResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
	assert.NotNil(t, response.User)
	assert.Equal(t, "Integration Test User", response.User.Name)
	assert.Equal(t, "integration@example.com", response.User.Email)
}

func TestAuthIntegration_Login(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/register", authHandler.Register)
	router.POST("/auth/login", authHandler.Login)

	// Register a user first
	registerRequest := domain.RegisterRequest{
		Name:     "Login Test User",
		Email:    "login@example.com",
		Password: "password123",
	}

	registerBody, err := json.Marshal(registerRequest)
	require.NoError(t, err)

	registerReq := httptest.NewRequest("POST", "/auth/register", bytes.NewBuffer(registerBody))
	registerReq.Header.Set("Content-Type", "application/json")

	registerW := httptest.NewRecorder()
	router.ServeHTTP(registerW, registerReq)

	require.Equal(t, http.StatusCreated, registerW.Code)

	// Test login
	loginRequest := domain.LoginRequest{
		Email:    "login@example.com",
		Password: "password123",
	}

	loginBody, err := json.Marshal(loginRequest)
	require.NoError(t, err)

	loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
	loginReq.Header.Set("Content-Type", "application/json")

	loginW := httptest.NewRecorder()
	router.ServeHTTP(loginW, loginReq)

	// Assert
	assert.Equal(t, http.StatusOK, loginW.Code)

	var response domain.AuthResponse
	err = json.Unmarshal(loginW.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
	assert.NotNil(t, response.User)
	assert.Equal(t, "login@example.com", response.User.Email)
}

func TestAuthIntegration_Login_InvalidCredentials(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/login", authHandler.Login)

	// Test data
	loginRequest := domain.LoginRequest{
		Email:    "nonexistent@example.com",
		Password: "password123",
	}

	requestBody, err := json.Marshal(loginRequest)
	require.NoError(t, err)

	// Test
	req := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(requestBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert
	assert.Equal(t, http.StatusUnauthorized, w.Code)

	var response domain.ErrorResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.Contains(t, response.Error, "invalid email or password")
}

func TestAuthIntegration_SocialAuth(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/social", authHandler.SocialAuth)

	// Test data
	socialRequest := domain.SocialAuthRequest{
		Provider:    "google",
		AccessToken: "google_access_token_123",
		Name:        "Google User",
		Email:       "google@example.com",
	}

	requestBody, err := json.Marshal(socialRequest)
	require.NoError(t, err)

	// Test
	req := httptest.NewRequest("POST", "/auth/social", bytes.NewBuffer(requestBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert
	assert.Equal(t, http.StatusOK, w.Code)

	var response domain.AuthResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)
	assert.NotNil(t, response.User)
	assert.Equal(t, "Google User", response.User.Name)
	assert.Equal(t, "google@example.com", response.User.Email)
	assert.Equal(t, "google", response.User.Provider)
}

func TestAuthIntegration_RefreshToken(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/register", authHandler.Register)
	router.POST("/auth/refresh", authHandler.RefreshToken)

	// Register a user first
	registerRequest := domain.RegisterRequest{
		Name:     "Refresh Test User",
		Email:    "refresh@example.com",
		Password: "password123",
	}

	registerBody, err := json.Marshal(registerRequest)
	require.NoError(t, err)

	registerReq := httptest.NewRequest("POST", "/auth/register", bytes.NewBuffer(registerBody))
	registerReq.Header.Set("Content-Type", "application/json")

	registerW := httptest.NewRecorder()
	router.ServeHTTP(registerW, registerReq)

	require.Equal(t, http.StatusCreated, registerW.Code)

	var registerResponse domain.AuthResponse
	err = json.Unmarshal(registerW.Body.Bytes(), &registerResponse)
	require.NoError(t, err)

	// Test refresh token
	refreshRequest := domain.RefreshTokenRequest{
		RefreshToken: registerResponse.RefreshToken,
	}

	refreshBody, err := json.Marshal(refreshRequest)
	require.NoError(t, err)

	refreshReq := httptest.NewRequest("POST", "/auth/refresh", bytes.NewBuffer(refreshBody))
	refreshReq.Header.Set("Content-Type", "application/json")

	refreshW := httptest.NewRecorder()
	router.ServeHTTP(refreshW, refreshReq)

	// Assert
	assert.Equal(t, http.StatusOK, refreshW.Code)

	var response domain.TokenResponse
	err = json.Unmarshal(refreshW.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response.AccessToken)
	assert.Equal(t, int64(15*60), response.ExpiresIn)
}

func TestAuthIntegration_RefreshToken_InvalidToken(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/refresh", authHandler.RefreshToken)

	// Test data
	refreshRequest := domain.RefreshTokenRequest{
		RefreshToken: "invalid_refresh_token",
	}

	requestBody, err := json.Marshal(refreshRequest)
	require.NoError(t, err)

	// Test
	req := httptest.NewRequest("POST", "/auth/refresh", bytes.NewBuffer(requestBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert
	assert.Equal(t, http.StatusUnauthorized, w.Code)

	var response domain.ErrorResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.Contains(t, response.Error, "invalid refresh token")
}

func TestAuthIntegration_Register_InvalidData(t *testing.T) {
	// Setup
	tc := config.SetupTestEnvironment(t)
	defer config.TeardownTestEnvironment(t, tc)

	// Setup dependencies
	userRepo := repository.NewUserRepository(tc.TestDB)
	refreshTokenRepo := repository.NewRefreshTokenRepository(tc.TestDB)
	passwordResetRepo := repository.NewPasswordResetRepository(tc.TestDB)
	jwtService := service.NewJWTService(tc.JWTSecret)
	passwordService := service.NewPasswordService()
	emailService := mocks.NewMockEmailService()

	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	authHandler := handler.NewAuthHandler(authUsecase)

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/auth/register", authHandler.Register)

	// Test data - missing required fields
	registerRequest := map[string]string{
		"name": "Test User",
		// Missing email and password
	}

	requestBody, err := json.Marshal(registerRequest)
	require.NoError(t, err)

	// Test
	req := httptest.NewRequest("POST", "/auth/register", bytes.NewBuffer(requestBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert
	assert.Equal(t, http.StatusBadRequest, w.Code)

	var response domain.ErrorResponse
	err = json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response.Error)
}
