// mocks/repository_mocks.go
package mocks

import (
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
)

// MockUserRepository is a mock implementation of UserRepository
type MockUserRepository struct {
	users           map[primitive.ObjectID]*domain.User
	usersByEmail    map[string]*domain.User
	usersByProvider map[string]*domain.User
}

// NewMockUserRepository creates a new mock user repository
func NewMockUserRepository() *MockUserRepository {
	return &MockUserRepository{
		users:           make(map[primitive.ObjectID]*domain.User),
		usersByEmail:    make(map[string]*domain.User),
		usersByProvider: make(map[string]*domain.User),
	}
}

// CreateUser creates a user in the mock repository
func (m *MockUserRepository) CreateUser(user *domain.User) (*domain.User, error) {
	if user.ID.IsZero() {
		user.ID = primitive.NewObjectID()
	}

	// Check if user with email already exists
	if _, exists := m.usersByEmail[user.Email]; exists {
		return nil, errors.New("user with this email already exists")
	}

	// Store user
	userCopy := *user
	m.users[user.ID] = &userCopy
	m.usersByEmail[user.Email] = &userCopy

	if user.Provider != "" && user.ProviderID != "" {
		providerKey := user.Provider + ":" + user.ProviderID
		m.usersByProvider[providerKey] = &userCopy
	}

	return &userCopy, nil
}

// GetUserByID gets a user by ID from the mock repository
func (m *MockUserRepository) GetUserByID(userID primitive.ObjectID) (*domain.User, error) {
	user, exists := m.users[userID]
	if !exists {
		return nil, errors.New("user not found")
	}
	return user, nil
}

// GetUserByEmail gets a user by email from the mock repository
func (m *MockUserRepository) GetUserByEmail(email string) (*domain.User, error) {
	user, exists := m.usersByEmail[email]
	if !exists {
		return nil, errors.New("user not found")
	}
	return user, nil
}

// GetUserByProviderID gets a user by provider and provider ID from the mock repository
func (m *MockUserRepository) GetUserByProviderID(provider, providerID string) (*domain.User, error) {
	providerKey := provider + ":" + providerID
	user, exists := m.usersByProvider[providerKey]
	if !exists {
		return nil, errors.New("user not found")
	}
	return user, nil
}

// UpdateUser updates a user in the mock repository
func (m *MockUserRepository) UpdateUser(user *domain.User) error {
	if _, exists := m.users[user.ID]; !exists {
		return errors.New("user not found")
	}

	// Update user
	userCopy := *user
	m.users[user.ID] = &userCopy
	m.usersByEmail[user.Email] = &userCopy

	if user.Provider != "" && user.ProviderID != "" {
		providerKey := user.Provider + ":" + user.ProviderID
		m.usersByProvider[providerKey] = &userCopy
	}

	return nil
}

// DeleteUser deletes a user from the mock repository
func (m *MockUserRepository) DeleteUser(userID primitive.ObjectID) error {
	user, exists := m.users[userID]
	if !exists {
		return errors.New("user not found")
	}

	// Remove from all maps
	delete(m.users, userID)
	delete(m.usersByEmail, user.Email)

	if user.Provider != "" && user.ProviderID != "" {
		providerKey := user.Provider + ":" + user.ProviderID
		delete(m.usersByProvider, providerKey)
	}

	return nil
}

// AddPushToken adds a push token to a user in the mock repository
func (m *MockUserRepository) AddPushToken(userID primitive.ObjectID, pushToken domain.PushToken) error {
	user, exists := m.users[userID]
	if !exists {
		return errors.New("user not found")
	}

	user.PushTokens = append(user.PushTokens, pushToken)
	return nil
}

// RemovePushToken removes a push token from a user in the mock repository
func (m *MockUserRepository) RemovePushToken(userID primitive.ObjectID, token string) error {
	user, exists := m.users[userID]
	if !exists {
		return errors.New("user not found")
	}
	filtered := make([]domain.PushToken, 0, len(user.PushTokens))
	for _, pt := range user.PushTokens {
		if pt.Token != token {
			filtered = append(filtered, pt)
		}
	}
	user.PushTokens = filtered
	return nil
}

// Reset clears all data from the mock repository
func (m *MockUserRepository) Reset() {
	m.users = make(map[primitive.ObjectID]*domain.User)
	m.usersByEmail = make(map[string]*domain.User)
	m.usersByProvider = make(map[string]*domain.User)
}

// MockRefreshTokenRepository is a mock implementation of RefreshTokenRepository
type MockRefreshTokenRepository struct {
	tokens map[string]*domain.RefreshToken
}

// NewMockRefreshTokenRepository creates a new mock refresh token repository
func NewMockRefreshTokenRepository() *MockRefreshTokenRepository {
	return &MockRefreshTokenRepository{
		tokens: make(map[string]*domain.RefreshToken),
	}
}

// CreateRefreshToken creates a refresh token in the mock repository
func (m *MockRefreshTokenRepository) CreateRefreshToken(token *domain.RefreshToken) error {
	if token.ID.IsZero() {
		token.ID = primitive.NewObjectID()
	}

	m.tokens[token.Token] = token
	return nil
}

// GetRefreshToken gets a refresh token from the mock repository
func (m *MockRefreshTokenRepository) GetRefreshToken(token string) (*domain.RefreshToken, error) {
	refreshToken, exists := m.tokens[token]
	if !exists {
		return nil, errors.New("refresh token not found")
	}
	return refreshToken, nil
}

// DeleteRefreshToken deletes a refresh token from the mock repository
func (m *MockRefreshTokenRepository) DeleteRefreshToken(token string) error {
	delete(m.tokens, token)
	return nil
}

// DeleteUserRefreshTokens deletes all refresh tokens for a user from the mock repository
func (m *MockRefreshTokenRepository) DeleteUserRefreshTokens(userID primitive.ObjectID) error {
	for token, refreshToken := range m.tokens {
		if refreshToken.UserID == userID {
			delete(m.tokens, token)
		}
	}
	return nil
}

// Reset clears all data from the mock repository
func (m *MockRefreshTokenRepository) Reset() {
	m.tokens = make(map[string]*domain.RefreshToken)
}

// MockPasswordResetRepository is a mock implementation of PasswordResetRepository
type MockPasswordResetRepository struct {
	resets map[string]*domain.PasswordReset
}

// NewMockPasswordResetRepository creates a new mock password reset repository
func NewMockPasswordResetRepository() *MockPasswordResetRepository {
	return &MockPasswordResetRepository{
		resets: make(map[string]*domain.PasswordReset),
	}
}

// CreatePasswordReset creates a password reset in the mock repository
func (m *MockPasswordResetRepository) CreatePasswordReset(reset *domain.PasswordReset) error {
	if reset.ID.IsZero() {
		reset.ID = primitive.NewObjectID()
	}

	m.resets[reset.Token] = reset
	return nil
}

// GetPasswordReset gets a password reset from the mock repository
func (m *MockPasswordResetRepository) GetPasswordReset(token string) (*domain.PasswordReset, error) {
	reset, exists := m.resets[token]
	if !exists {
		return nil, errors.New("password reset not found")
	}
	return reset, nil
}

// MarkPasswordResetUsed marks a password reset as used in the mock repository
func (m *MockPasswordResetRepository) MarkPasswordResetUsed(token string) error {
	reset, exists := m.resets[token]
	if !exists {
		return errors.New("password reset not found")
	}

	reset.Used = true
	return nil
}

// DeleteExpiredResets deletes all expired password resets from the mock repository
func (m *MockPasswordResetRepository) DeleteExpiredResets() error {
	for k, v := range m.resets {
		if v.ExpiresAt.Before(time.Now()) {
			delete(m.resets, k)
		}
	}
	return nil
}

// Reset clears all data from the mock repository
func (m *MockPasswordResetRepository) Reset() {
	m.resets = make(map[string]*domain.PasswordReset)
}

// MockLearningRepository is a mock implementation of LearningRepository
type MockLearningRepository struct {
	paths           map[primitive.ObjectID]*domain.LearningPath
	lessons         map[primitive.ObjectID]*domain.Lesson
	quizzes         map[primitive.ObjectID]*domain.Quiz
	userProgress    map[primitive.ObjectID]*domain.UserProgress
	quizSubmissions map[primitive.ObjectID]*domain.QuizSubmission
}

// NewMockLearningRepository creates a new mock learning repository
func NewMockLearningRepository() *MockLearningRepository {
	return &MockLearningRepository{
		paths:           make(map[primitive.ObjectID]*domain.LearningPath),
		lessons:         make(map[primitive.ObjectID]*domain.Lesson),
		quizzes:         make(map[primitive.ObjectID]*domain.Quiz),
		userProgress:    make(map[primitive.ObjectID]*domain.UserProgress),
		quizSubmissions: make(map[primitive.ObjectID]*domain.QuizSubmission),
	}
}

// GetAllLearningPaths gets all learning paths from the mock repository
func (m *MockLearningRepository) GetAllLearningPaths() ([]*domain.LearningPath, error) {
	var paths []*domain.LearningPath
	for _, path := range m.paths {
		paths = append(paths, path)
	}
	return paths, nil
}

// GetLearningPathByID gets a learning path by ID from the mock repository
func (m *MockLearningRepository) GetLearningPathByID(pathID primitive.ObjectID) (*domain.LearningPath, error) {
	path, exists := m.paths[pathID]
	if !exists {
		return nil, errors.New("learning path not found")
	}
	return path, nil
}

// GetLessonByID gets a lesson by ID from the mock repository
func (m *MockLearningRepository) GetLessonByID(lessonID primitive.ObjectID) (*domain.Lesson, error) {
	lesson, exists := m.lessons[lessonID]
	if !exists {
		return nil, errors.New("lesson not found")
	}
	return lesson, nil
}

// GetQuizByID gets a quiz by ID from the mock repository
func (m *MockLearningRepository) GetQuizByID(quizID primitive.ObjectID) (*domain.Quiz, error) {
	quiz, exists := m.quizzes[quizID]
	if !exists {
		return nil, errors.New("quiz not found")
	}
	return quiz, nil
}

// GetUserProgress gets user progress from the mock repository
func (m *MockLearningRepository) GetUserProgress(userID, pathID primitive.ObjectID) (*domain.UserProgress, error) {
	progress, exists := m.userProgress[pathID]
	if !exists {
		return nil, errors.New("user progress not found")
	}
	return progress, nil
}

// CreateUserProgress creates user progress in the mock repository
func (m *MockLearningRepository) CreateUserProgress(progress *domain.UserProgress) error {
	if progress.ID.IsZero() {
		progress.ID = primitive.NewObjectID()
	}

	m.userProgress[progress.PathID] = progress
	return nil
}

// UpdateUserProgress updates user progress in the mock repository
func (m *MockLearningRepository) UpdateUserProgress(progress *domain.UserProgress) error {
	if _, exists := m.userProgress[progress.PathID]; !exists {
		return errors.New("user progress not found")
	}

	m.userProgress[progress.PathID] = progress
	return nil
}

// CreateQuizSubmission creates a quiz submission in the mock repository
func (m *MockLearningRepository) CreateQuizSubmission(submission *domain.QuizSubmission) error {
	if submission.ID.IsZero() {
		submission.ID = primitive.NewObjectID()
	}

	m.quizSubmissions[submission.ID] = submission
	return nil
}

// Reset clears all data from the mock repository
func (m *MockLearningRepository) Reset() {
	m.paths = make(map[primitive.ObjectID]*domain.LearningPath)
	m.lessons = make(map[primitive.ObjectID]*domain.Lesson)
	m.quizzes = make(map[primitive.ObjectID]*domain.Quiz)
	m.userProgress = make(map[primitive.ObjectID]*domain.UserProgress)
	m.quizSubmissions = make(map[primitive.ObjectID]*domain.QuizSubmission)
}
