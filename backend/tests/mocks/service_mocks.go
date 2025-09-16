// mocks/service_mocks.go
package mocks

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
)

// MockJWTService is a mock implementation of JWTService
type MockJWTService struct {
	secretKey string
	tokens    map[string]primitive.ObjectID
}

// NewMockJWTService creates a new mock JWT service
func NewMockJWTService(secretKey string) *MockJWTService {
	return &MockJWTService{
		secretKey: secretKey,
		tokens:    make(map[string]primitive.ObjectID),
	}
}

// GenerateAccessToken generates a mock access token
func (m *MockJWTService) GenerateAccessToken(userID primitive.ObjectID) (string, error) {
	token := "mock_access_token_" + userID.Hex()
	m.tokens[token] = userID
	return token, nil
}

// GenerateRefreshToken generates a mock refresh token
func (m *MockJWTService) GenerateRefreshToken() (string, error) {
	return "mock_refresh_token_" + primitive.NewObjectID().Hex(), nil
}

// ValidateAccessToken validates a mock access token
func (m *MockJWTService) ValidateAccessToken(tokenString string) (*jwt.Token, error) {
	if tokenString == "invalid_token" {
		return nil, errors.New("invalid token")
	}

	// Create a mock JWT token
	claims := &jwt.RegisteredClaims{
		Subject: m.tokens[tokenString].Hex(),
	}

	token := &jwt.Token{
		Valid:  true,
		Claims: claims,
	}

	return token, nil
}

// ExtractUserID extracts user ID from a mock token
func (m *MockJWTService) ExtractUserID(token *jwt.Token) (primitive.ObjectID, error) {
	claims, ok := token.Claims.(*jwt.RegisteredClaims)
	if !ok {
		return primitive.NilObjectID, errors.New("invalid token claims")
	}

	userID, err := primitive.ObjectIDFromHex(claims.Subject)
	if err != nil {
		return primitive.NilObjectID, err
	}

	return userID, nil
}

// Reset clears all data from the mock service
func (m *MockJWTService) Reset() {
	m.tokens = make(map[string]primitive.ObjectID)
}

// MockPasswordService is a mock implementation of PasswordService
type MockPasswordService struct {
	hashedPasswords map[string]string
}

// NewMockPasswordService creates a new mock password service
func NewMockPasswordService() *MockPasswordService {
	return &MockPasswordService{
		hashedPasswords: make(map[string]string),
	}
}

// HashPassword hashes a password using mock logic
func (m *MockPasswordService) HashPassword(password string) (string, error) {
	// Simple mock hashing - just prefix with "hashed_"
	hashed := "hashed_" + password
	m.hashedPasswords[hashed] = password
	return hashed, nil
}

// CheckPassword checks a password against a hash using mock logic
func (m *MockPasswordService) CheckPassword(password, hash string) bool {
	expectedPassword, exists := m.hashedPasswords[hash]
	if !exists {
		return false
	}
	return password == expectedPassword
}

// Reset clears all data from the mock service
func (m *MockPasswordService) Reset() {
	m.hashedPasswords = make(map[string]string)
}

// MockEmailService is a mock implementation of EmailService
type MockEmailService struct {
	sentEmails []SentEmail
}

// SentEmail represents an email sent through the mock service
type SentEmail struct {
	To      string
	Subject string
	Body    string
	Type    string
}

// NewMockEmailService creates a new mock email service
func NewMockEmailService() *MockEmailService {
	return &MockEmailService{
		sentEmails: make([]SentEmail, 0),
	}
}

// SendPasswordResetEmail sends a mock password reset email
func (m *MockEmailService) SendPasswordResetEmail(email, token, name string) error {
	sentEmail := SentEmail{
		To:      email,
		Subject: "Password Reset",
		Body:    "Reset your password with token: " + token,
		Type:    "password_reset",
	}
	m.sentEmails = append(m.sentEmails, sentEmail)
	return nil
}

// SendWelcomeEmail sends a mock welcome email
func (m *MockEmailService) SendWelcomeEmail(email, name string) error {
	sentEmail := SentEmail{
		To:      email,
		Subject: "Welcome to LissanAI",
		Body:    "Welcome " + name + "!",
		Type:    "welcome",
	}
	m.sentEmails = append(m.sentEmails, sentEmail)
	return nil
}

// GetSentEmails returns all sent emails
func (m *MockEmailService) GetSentEmails() []SentEmail {
	return m.sentEmails
}

// GetSentEmailsByType returns sent emails by type
func (m *MockEmailService) GetSentEmailsByType(emailType string) []SentEmail {
	var filtered []SentEmail
	for _, email := range m.sentEmails {
		if email.Type == emailType {
			filtered = append(filtered, email)
		}
	}
	return filtered
}

// Reset clears all data from the mock service
func (m *MockEmailService) Reset() {
	m.sentEmails = make([]SentEmail, 0)
}

// MockStreakService is a mock implementation of StreakService
type MockStreakService struct {
	userStreaks map[primitive.ObjectID]*domain.StreakInfo
	activities  map[primitive.ObjectID][]domain.StreakActivity
}

// NewMockStreakService creates a new mock streak service
func NewMockStreakService() *MockStreakService {
	return &MockStreakService{
		userStreaks: make(map[primitive.ObjectID]*domain.StreakInfo),
		activities:  make(map[primitive.ObjectID][]domain.StreakActivity),
	}
}

// GetStreakInfo gets streak info for a user
func (m *MockStreakService) GetStreakInfo(userID primitive.ObjectID) (*domain.StreakInfo, error) {
	streakInfo, exists := m.userStreaks[userID]
	if !exists {
		return &domain.StreakInfo{
			CurrentStreak:    0,
			LongestStreak:    0,
			LastActivityDate: time.Time{},
			StreakFrozen:     false,
			FreezeCount:      0,
			MaxFreezes:       3,
			CanFreeze:        true,
			DaysUntilLoss:    0,
		}, nil
	}
	return streakInfo, nil
}

// RecordActivity records a streak activity
func (m *MockStreakService) RecordActivity(userID primitive.ObjectID, activityType string) error {
	activity := domain.StreakActivity{
		ID:           primitive.NewObjectID(),
		UserID:       userID,
		ActivityType: activityType,
		Date:         time.Now(),
		CreatedAt:    time.Now(),
	}

	m.activities[userID] = append(m.activities[userID], activity)
	return nil
}

// FreezeStreak freezes a user's streak
func (m *MockStreakService) FreezeStreak(userID primitive.ObjectID, reason string) error {
	streakInfo, exists := m.userStreaks[userID]
	if !exists {
		streakInfo = &domain.StreakInfo{
			CurrentStreak:    0,
			LongestStreak:    0,
			LastActivityDate: time.Time{},
			StreakFrozen:     false,
			FreezeCount:      0,
			MaxFreezes:       3,
			CanFreeze:        true,
			DaysUntilLoss:    0,
		}
	}

	if streakInfo.FreezeCount >= streakInfo.MaxFreezes {
		return errors.New("maximum freeze count reached")
	}

	streakInfo.StreakFrozen = true
	streakInfo.FreezeCount++
	streakInfo.CanFreeze = streakInfo.FreezeCount < streakInfo.MaxFreezes

	m.userStreaks[userID] = streakInfo
	return nil
}

// UnfreezeStreak unfreezes a user's streak
func (m *MockStreakService) UnfreezeStreak(userID primitive.ObjectID) error {
	streakInfo, exists := m.userStreaks[userID]
	if !exists {
		return errors.New("streak info not found")
	}

	streakInfo.StreakFrozen = false
	m.userStreaks[userID] = streakInfo
	return nil
}

// GetActivityCalendar gets activity calendar for a user
func (m *MockStreakService) GetActivityCalendar(userID primitive.ObjectID, year int) (*domain.ActivityCalendarResponse, error) {
	activities := m.activities[userID]

	// Simple mock implementation
	response := &domain.ActivityCalendarResponse{
		Year:          year,
		TotalDays:     365,
		ActiveDays:    len(activities),
		CurrentStreak: 0,
		LongestStreak: 0,
		Weeks:         []domain.ActivityCalendarWeek{},
		Summary: domain.ActivityCalendarSummary{
			TotalActivities:   len(activities),
			ActivityBreakdown: make(map[string]int),
			MostActiveDay:     "",
			MostActiveCount:   0,
			ConsecutiveWeeks:  0,
		},
	}

	return response, nil
}

// Reset clears all data from the mock service
func (m *MockStreakService) Reset() {
	m.userStreaks = make(map[primitive.ObjectID]*domain.StreakInfo)
	m.activities = make(map[primitive.ObjectID][]domain.StreakActivity)
}
