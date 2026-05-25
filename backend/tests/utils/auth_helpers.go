// utils/auth_helpers.go
package utils

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/service"
)

// AuthHelper provides helper functions for authentication in tests
type AuthHelper struct {
	JWTService service.JWTService
}

// NewAuthHelper creates a new auth helper
func NewAuthHelper(jwtService service.JWTService) *AuthHelper {
	return &AuthHelper{JWTService: jwtService}
}

// GenerateTestAccessToken generates a test access token
func (h *AuthHelper) GenerateTestAccessToken(t *testing.T, userID primitive.ObjectID) string {
	token, err := h.JWTService.GenerateAccessToken(userID)
	if err != nil {
		t.Fatalf("Failed to generate test access token: %v", err)
	}
	return token
}

// GenerateTestRefreshToken generates a test refresh token
func (h *AuthHelper) GenerateTestRefreshToken(t *testing.T) string {
	token, err := h.JWTService.GenerateRefreshToken()
	if err != nil {
		t.Fatalf("Failed to generate test refresh token: %v", err)
	}
	return token
}

// ValidateTestAccessToken validates a test access token
func (h *AuthHelper) ValidateTestAccessToken(t *testing.T, tokenString string) *jwt.Token {
	token, err := h.JWTService.ValidateAccessToken(tokenString)
	if err != nil {
		t.Fatalf("Failed to validate test access token: %v", err)
	}
	return token
}

// ExtractUserIDFromToken extracts user ID from a token
func (h *AuthHelper) ExtractUserIDFromToken(t *testing.T, token *jwt.Token) primitive.ObjectID {
	userID, err := h.JWTService.ExtractUserID(token)
	if err != nil {
		t.Fatalf("Failed to extract user ID from token: %v", err)
	}
	return userID
}

// CreateTestAuthResponse creates a test auth response
func (h *AuthHelper) CreateTestAuthResponse(t *testing.T, user *domain.User) *domain.AuthResponse {
	accessToken := h.GenerateTestAccessToken(t, user.ID)
	refreshToken := h.GenerateTestRefreshToken(t)

	return &domain.AuthResponse{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    15 * 60, // 15 minutes
	}
}

// CreateTestLoginRequest creates a test login request
func CreateTestLoginRequest(email, password string) *domain.LoginRequest {
	return &domain.LoginRequest{
		Email:    email,
		Password: password,
	}
}

// CreateTestRegisterRequest creates a test register request
func CreateTestRegisterRequest(name, email, password string) *domain.RegisterRequest {
	return &domain.RegisterRequest{
		Name:     name,
		Email:    email,
		Password: password,
	}
}

// CreateTestSocialAuthRequest creates a test social auth request
func CreateTestSocialAuthRequest(provider, accessToken, name, email string) *domain.SocialAuthRequest {
	return &domain.SocialAuthRequest{
		Provider:    provider,
		AccessToken: accessToken,
		Name:        name,
		Email:       email,
	}
}

// CreateTestRefreshTokenRequest creates a test refresh token request
func CreateTestRefreshTokenRequest(refreshToken string) *domain.RefreshTokenRequest {
	return &domain.RefreshTokenRequest{
		RefreshToken: refreshToken,
	}
}

// CreateTestForgotPasswordRequest creates a test forgot password request
func CreateTestForgotPasswordRequest(email string) *domain.ForgotPasswordRequest {
	return &domain.ForgotPasswordRequest{
		Email: email,
	}
}

// CreateTestResetPasswordRequest creates a test reset password request
func CreateTestResetPasswordRequest(token, newPassword string) *domain.ResetPasswordRequest {
	return &domain.ResetPasswordRequest{
		Token:       token,
		NewPassword: newPassword,
	}
}

// CreateTestUpdateProfileRequest creates a test update profile request
func CreateTestUpdateProfileRequest(name string, settings map[string]interface{}) *domain.UpdateProfileRequest {
	return &domain.UpdateProfileRequest{
		Name:     &name,
		Settings: settings,
	}
}

// CreateTestPushTokenRequest creates a test push token request
func CreateTestPushTokenRequest(token, platform string) *domain.PushTokenRequest {
	return &domain.PushTokenRequest{
		Token:    token,
		Platform: platform,
	}
}

// CreateTestUserWithStreak creates a test user with streak information
func CreateTestUserWithStreak(t *testing.T, name, email string, currentStreak, longestStreak int, lastActivityDate time.Time) *domain.User {
	user := CreateTestUser(t, name, email)
	user.CurrentStreak = currentStreak
	user.LongestStreak = longestStreak
	user.LastActivityDate = lastActivityDate
	return user
}

// CreateTestUserWithProvider creates a test user with OAuth provider information
func CreateTestUserWithProvider(t *testing.T, name, email, provider, providerID string) *domain.User {
	user := CreateTestUser(t, name, email)
	user.Provider = provider
	user.ProviderID = providerID
	user.PasswordHash = "" // No password for OAuth users
	return user
}

// CreateTestUserWithSettings creates a test user with custom settings
func CreateTestUserWithSettings(t *testing.T, name, email string, settings map[string]interface{}) *domain.User {
	user := CreateTestUser(t, name, email)
	user.Settings = settings
	return user
}

// CreateTestUserWithStreakFrozen creates a test user with frozen streak
func CreateTestUserWithStreakFrozen(t *testing.T, name, email string, freezeCount int) *domain.User {
	user := CreateTestUser(t, name, email)
	user.StreakFrozen = true
	user.FreezeCount = freezeCount
	return user
}

// AssertAuthResponseValid asserts that an auth response is valid
func AssertAuthResponseValid(t *testing.T, response *domain.AuthResponse) {
	if response == nil {
		t.Fatal("Auth response should not be nil")
	}

	if response.User == nil {
		t.Fatal("Auth response user should not be nil")
	}

	if response.AccessToken == "" {
		t.Fatal("Auth response access token should not be empty")
	}

	if response.RefreshToken == "" {
		t.Fatal("Auth response refresh token should not be empty")
	}

	if response.ExpiresIn <= 0 {
		t.Fatal("Auth response expires in should be positive")
	}
}

// AssertUserAuthenticated asserts that a user is properly authenticated
func AssertUserAuthenticated(t *testing.T, user *domain.User, expectedEmail string) {
	if user == nil {
		t.Fatal("User should not be nil")
	}

	if user.Email != expectedEmail {
		t.Fatalf("Expected user email %s, got %s", expectedEmail, user.Email)
	}

	if user.ID.IsZero() {
		t.Fatal("User ID should not be zero")
	}
}

// AssertTokenValid asserts that a JWT token is valid
func AssertTokenValid(t *testing.T, tokenString string, jwtService service.JWTService) {
	token, err := jwtService.ValidateAccessToken(tokenString)
	if err != nil {
		t.Fatalf("Token should be valid: %v", err)
	}

	if !token.Valid {
		t.Fatal("Token should be valid")
	}
}

// AssertTokenExpired asserts that a JWT token is expired
func AssertTokenExpired(t *testing.T, tokenString string, jwtService service.JWTService) {
	_, err := jwtService.ValidateAccessToken(tokenString)
	if err == nil {
		t.Fatal("Token should be expired")
	}
}

// CreateExpiredToken creates an expired JWT token for testing
func CreateExpiredToken(t *testing.T, userID primitive.ObjectID, secret string) string {
	claims := jwt.RegisteredClaims{
		Subject:   userID.Hex(),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(-time.Hour)), // Expired 1 hour ago
		IssuedAt:  jwt.NewNumericDate(time.Now().Add(-2 * time.Hour)),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		t.Fatalf("Failed to create expired token: %v", err)
	}

	return tokenString
}

// CreateInvalidToken creates an invalid JWT token for testing
func CreateInvalidToken(t *testing.T) string {
	return "invalid.jwt.token"
}

// CreateMalformedToken creates a malformed JWT token for testing
func CreateMalformedToken(t *testing.T) string {
	return "malformed-token"
}
