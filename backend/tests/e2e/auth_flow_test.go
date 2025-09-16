// e2e/auth_flow_test.go
package e2e

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
	"lissanai.com/backend/internal/middleware"
	"lissanai.com/backend/internal/repository"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
	"lissanai.com/backend/tests/config"
	"lissanai.com/backend/tests/mocks"
)

func TestE2E_CompleteAuthFlow(t *testing.T) {
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
	userUsecase := usecase.NewUserUsecase(userRepo, refreshTokenRepo)

	authHandler := handler.NewAuthHandler(authUsecase)
	userHandler := handler.NewUserHandler(userUsecase)

	// Setup router with all auth routes
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Auth routes
	auth := router.Group("/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/social", authHandler.SocialAuth)
		auth.POST("/refresh", authHandler.RefreshToken)
		auth.POST("/forgot-password", authHandler.ForgotPassword)
		auth.POST("/reset-password", authHandler.ResetPassword)
		auth.POST("/logout", middleware.AuthMiddleware(jwtService), authHandler.Logout)
	}

	// User routes (protected)
	users := router.Group("/users")
	users.Use(middleware.AuthMiddleware(jwtService))
	{
		users.GET("/me", userHandler.GetProfile)
		users.PATCH("/me", userHandler.UpdateProfile)
		users.DELETE("/me", userHandler.DeleteAccount)
		users.POST("/me/push-token", userHandler.AddPushToken)
	}

	// Test 1: Register a new user
	t.Run("RegisterUser", func(t *testing.T) {
		registerRequest := domain.RegisterRequest{
			Name:     "E2E Test User",
			Email:    "e2e@example.com",
			Password: "password123",
		}

		requestBody, err := json.Marshal(registerRequest)
		require.NoError(t, err)

		req := httptest.NewRequest("POST", "/auth/register", bytes.NewBuffer(requestBody))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		var response domain.AuthResponse
		err = json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)

		assert.NotEmpty(t, response.AccessToken)
		assert.NotEmpty(t, response.RefreshToken)
		assert.NotNil(t, response.User)
		assert.Equal(t, "E2E Test User", response.User.Name)
		assert.Equal(t, "e2e@example.com", response.User.Email)
	})

	// Test 2: Login with registered user
	t.Run("LoginUser", func(t *testing.T) {
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		requestBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		req := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(requestBody))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var response domain.AuthResponse
		err = json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)

		assert.NotEmpty(t, response.AccessToken)
		assert.NotEmpty(t, response.RefreshToken)
		assert.NotNil(t, response.User)
		assert.Equal(t, "e2e@example.com", response.User.Email)
	})

	// Test 3: Access protected route
	t.Run("AccessProtectedRoute", func(t *testing.T) {
		// First login to get token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now access protected route
		req := httptest.NewRequest("GET", "/users/me", nil)
		req.Header.Set("Authorization", "Bearer "+loginResponse.AccessToken)

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var userResponse domain.User
		err = json.Unmarshal(w.Body.Bytes(), &userResponse)
		require.NoError(t, err)

		assert.Equal(t, "E2E Test User", userResponse.Name)
		assert.Equal(t, "e2e@example.com", userResponse.Email)
	})

	// Test 4: Refresh token
	t.Run("RefreshToken", func(t *testing.T) {
		// First login to get refresh token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now refresh token
		refreshRequest := domain.RefreshTokenRequest{
			RefreshToken: loginResponse.RefreshToken,
		}

		refreshBody, err := json.Marshal(refreshRequest)
		require.NoError(t, err)

		refreshReq := httptest.NewRequest("POST", "/auth/refresh", bytes.NewBuffer(refreshBody))
		refreshReq.Header.Set("Content-Type", "application/json")

		refreshW := httptest.NewRecorder()
		router.ServeHTTP(refreshW, refreshReq)

		assert.Equal(t, http.StatusOK, refreshW.Code)

		var refreshResponse domain.TokenResponse
		err = json.Unmarshal(refreshW.Body.Bytes(), &refreshResponse)
		require.NoError(t, err)

		assert.NotEmpty(t, refreshResponse.AccessToken)
		assert.Equal(t, int64(15*60), refreshResponse.ExpiresIn)
	})

	// Test 5: Update profile
	t.Run("UpdateProfile", func(t *testing.T) {
		// First login to get token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now update profile
		updateRequest := domain.UpdateProfileRequest{
			Name: stringPtr("Updated E2E Test User"),
			Settings: map[string]interface{}{
				"theme":    "dark",
				"language": "en",
			},
		}

		updateBody, err := json.Marshal(updateRequest)
		require.NoError(t, err)

		updateReq := httptest.NewRequest("PATCH", "/users/me", bytes.NewBuffer(updateBody))
		updateReq.Header.Set("Content-Type", "application/json")
		updateReq.Header.Set("Authorization", "Bearer "+loginResponse.AccessToken)

		updateW := httptest.NewRecorder()
		router.ServeHTTP(updateW, updateReq)

		assert.Equal(t, http.StatusOK, updateW.Code)

		var userResponse domain.User
		err = json.Unmarshal(updateW.Body.Bytes(), &userResponse)
		require.NoError(t, err)

		assert.Equal(t, "Updated E2E Test User", userResponse.Name)
		assert.Equal(t, "dark", userResponse.Settings["theme"])
		assert.Equal(t, "en", userResponse.Settings["language"])
	})

	// Test 6: Add push token
	t.Run("AddPushToken", func(t *testing.T) {
		// First login to get token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now add push token
		pushTokenRequest := domain.PushTokenRequest{
			Token:    "test_push_token_123",
			Platform: "ios",
		}

		pushTokenBody, err := json.Marshal(pushTokenRequest)
		require.NoError(t, err)

		pushTokenReq := httptest.NewRequest("POST", "/users/me/push-token", bytes.NewBuffer(pushTokenBody))
		pushTokenReq.Header.Set("Content-Type", "application/json")
		pushTokenReq.Header.Set("Authorization", "Bearer "+loginResponse.AccessToken)

		pushTokenW := httptest.NewRecorder()
		router.ServeHTTP(pushTokenW, pushTokenReq)

		assert.Equal(t, http.StatusOK, pushTokenW.Code)

		var messageResponse domain.MessageResponse
		err = json.Unmarshal(pushTokenW.Body.Bytes(), &messageResponse)
		require.NoError(t, err)

		assert.Contains(t, messageResponse.Message, "successfully")
	})

	// Test 7: Logout
	t.Run("Logout", func(t *testing.T) {
		// First login to get token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now logout
		logoutRequest := domain.RefreshTokenRequest{
			RefreshToken: loginResponse.RefreshToken,
		}

		logoutBody, err := json.Marshal(logoutRequest)
		require.NoError(t, err)

		logoutReq := httptest.NewRequest("POST", "/auth/logout", bytes.NewBuffer(logoutBody))
		logoutReq.Header.Set("Content-Type", "application/json")
		logoutReq.Header.Set("Authorization", "Bearer "+loginResponse.AccessToken)

		logoutW := httptest.NewRecorder()
		router.ServeHTTP(logoutW, logoutReq)

		assert.Equal(t, http.StatusOK, logoutW.Code)

		var messageResponse domain.MessageResponse
		err = json.Unmarshal(logoutW.Body.Bytes(), &messageResponse)
		require.NoError(t, err)

		assert.Contains(t, messageResponse.Message, "Successfully logged out")
	})

	// Test 8: Delete account
	t.Run("DeleteAccount", func(t *testing.T) {
		// First login to get token
		loginRequest := domain.LoginRequest{
			Email:    "e2e@example.com",
			Password: "password123",
		}

		loginBody, err := json.Marshal(loginRequest)
		require.NoError(t, err)

		loginReq := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq.Header.Set("Content-Type", "application/json")

		loginW := httptest.NewRecorder()
		router.ServeHTTP(loginW, loginReq)

		require.Equal(t, http.StatusOK, loginW.Code)

		var loginResponse domain.AuthResponse
		err = json.Unmarshal(loginW.Body.Bytes(), &loginResponse)
		require.NoError(t, err)

		// Now delete account
		deleteReq := httptest.NewRequest("DELETE", "/users/me", nil)
		deleteReq.Header.Set("Authorization", "Bearer "+loginResponse.AccessToken)

		deleteW := httptest.NewRecorder()
		router.ServeHTTP(deleteW, deleteReq)

		assert.Equal(t, http.StatusOK, deleteW.Code)

		var messageResponse domain.MessageResponse
		err = json.Unmarshal(deleteW.Body.Bytes(), &messageResponse)
		require.NoError(t, err)

		assert.Contains(t, messageResponse.Message, "Account deleted successfully")

		// Verify user can no longer login
		loginReq2 := httptest.NewRequest("POST", "/auth/login", bytes.NewBuffer(loginBody))
		loginReq2.Header.Set("Content-Type", "application/json")

		loginW2 := httptest.NewRecorder()
		router.ServeHTTP(loginW2, loginReq2)

		assert.Equal(t, http.StatusUnauthorized, loginW2.Code)
	})
}

// Helper function to create string pointer
func stringPtr(s string) *string {
	return &s
}
