package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/tests/mocks"
)

func TestAuthHandler_Register(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		request        domain.RegisterRequest
		mockSetup      func(*mocks.MockAuthUsecase)
		expectedStatus int
		expectedError  string
	}{
		{
			name: "Successful registration",
			request: domain.RegisterRequest{
				Name:     "Test User",
				Email:    "test@example.com",
				Password: "password123",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("Register", mock.AnythingOfType("*domain.RegisterRequest")).Return(
					&domain.AuthResponse{
						AccessToken:  "access_token",
						RefreshToken: "refresh_token",
						User: &domain.User{
							ID:    primitive.NewObjectID(),
							Name:  "Test User",
							Email: "test@example.com",
						},
					}, nil)
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Invalid email format",
			request: domain.RegisterRequest{
				Name:     "Test User",
				Email:    "invalid-email",
				Password: "password123",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("Register", mock.AnythingOfType("*domain.RegisterRequest")).Return(
					nil, assert.AnError)
			},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockUsecase := &mocks.MockAuthUsecase{}
			tt.mockSetup(mockUsecase)

			authHandler := handler.NewAuthHandler(mockUsecase)
			router := gin.New()
			router.POST("/register", authHandler.Register)

			requestBody, _ := json.Marshal(tt.request)
			req := httptest.NewRequest("POST", "/register", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
			mockUsecase.AssertExpectations(t)
		})
	}
}

func TestAuthHandler_Login(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		request        domain.LoginRequest
		mockSetup      func(*mocks.MockAuthUsecase)
		expectedStatus int
	}{
		{
			name: "Successful login",
			request: domain.LoginRequest{
				Email:    "test@example.com",
				Password: "password123",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("Login", mock.AnythingOfType("*domain.LoginRequest")).Return(
					&domain.AuthResponse{
						AccessToken:  "access_token",
						RefreshToken: "refresh_token",
						User: &domain.User{
							ID:    primitive.NewObjectID(),
							Name:  "Test User",
							Email: "test@example.com",
						},
					}, nil)
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "Invalid credentials",
			request: domain.LoginRequest{
				Email:    "test@example.com",
				Password: "wrongpassword",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("Login", mock.AnythingOfType("*domain.LoginRequest")).Return(
					nil, assert.AnError)
			},
			expectedStatus: http.StatusUnauthorized,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockUsecase := &mocks.MockAuthUsecase{}
			tt.mockSetup(mockUsecase)

			authHandler := handler.NewAuthHandler(mockUsecase)
			router := gin.New()
			router.POST("/login", authHandler.Login)

			requestBody, _ := json.Marshal(tt.request)
			req := httptest.NewRequest("POST", "/login", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
			mockUsecase.AssertExpectations(t)
		})
	}
}

func TestAuthHandler_SocialAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		request        domain.SocialAuthRequest
		mockSetup      func(*mocks.MockAuthUsecase)
		expectedStatus int
	}{
		{
			name: "Successful social auth",
			request: domain.SocialAuthRequest{
				Provider:    "google",
				AccessToken: "google_token",
				Name:        "Test User",
				Email:       "test@example.com",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("SocialAuth", mock.AnythingOfType("*domain.SocialAuthRequest")).Return(
					&domain.AuthResponse{
						AccessToken:  "access_token",
						RefreshToken: "refresh_token",
						User: &domain.User{
							ID:    primitive.NewObjectID(),
							Name:  "Test User",
							Email: "test@example.com",
						},
					}, nil)
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "Invalid provider",
			request: domain.SocialAuthRequest{
				Provider:    "invalid",
				AccessToken: "token",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("SocialAuth", mock.AnythingOfType("*domain.SocialAuthRequest")).Return(
					nil, assert.AnError)
			},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockUsecase := &mocks.MockAuthUsecase{}
			tt.mockSetup(mockUsecase)

			authHandler := handler.NewAuthHandler(mockUsecase)
			router := gin.New()
			router.POST("/social", authHandler.SocialAuth)

			requestBody, _ := json.Marshal(tt.request)
			req := httptest.NewRequest("POST", "/social", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
			mockUsecase.AssertExpectations(t)
		})
	}
}

func TestAuthHandler_RefreshToken(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		request        domain.RefreshTokenRequest
		mockSetup      func(*mocks.MockAuthUsecase)
		expectedStatus int
	}{
		{
			name: "Successful refresh",
			request: domain.RefreshTokenRequest{
				RefreshToken: "valid_refresh_token",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("RefreshToken", mock.AnythingOfType("*domain.RefreshTokenRequest")).Return(
					&domain.TokenResponse{
						AccessToken: "new_access_token",
						ExpiresIn:   900,
					}, nil)
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "Invalid refresh token",
			request: domain.RefreshTokenRequest{
				RefreshToken: "invalid_token",
			},
			mockSetup: func(m *mocks.MockAuthUsecase) {
				m.On("RefreshToken", mock.AnythingOfType("*domain.RefreshTokenRequest")).Return(
					nil, assert.AnError)
			},
			expectedStatus: http.StatusUnauthorized,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockUsecase := &mocks.MockAuthUsecase{}
			tt.mockSetup(mockUsecase)

			authHandler := handler.NewAuthHandler(mockUsecase)
			router := gin.New()
			router.POST("/refresh", authHandler.RefreshToken)

			requestBody, _ := json.Marshal(tt.request)
			req := httptest.NewRequest("POST", "/refresh", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
			mockUsecase.AssertExpectations(t)
		})
	}
}
