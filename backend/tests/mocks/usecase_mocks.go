// mocks/usecase_mocks.go
package mocks

import (
	"github.com/stretchr/testify/mock"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/domain/models"
)

// MockAuthUsecase is a mock implementation of AuthUsecase
type MockAuthUsecase struct {
	mock.Mock
}

func (m *MockAuthUsecase) Register(req *domain.RegisterRequest) (*domain.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.AuthResponse), args.Error(1)
}

func (m *MockAuthUsecase) Login(req *domain.LoginRequest) (*domain.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.AuthResponse), args.Error(1)
}

func (m *MockAuthUsecase) SocialAuth(req *domain.SocialAuthRequest) (*domain.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.AuthResponse), args.Error(1)
}

func (m *MockAuthUsecase) RefreshToken(req *domain.RefreshTokenRequest) (*domain.TokenResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.TokenResponse), args.Error(1)
}

func (m *MockAuthUsecase) Logout(userID primitive.ObjectID, refreshToken string) error {
	args := m.Called(userID, refreshToken)
	return args.Error(0)
}

func (m *MockAuthUsecase) ForgotPassword(req *domain.ForgotPasswordRequest) error {
	args := m.Called(req)
	return args.Error(0)
}

func (m *MockAuthUsecase) ResetPassword(req *domain.ResetPasswordRequest) error {
	args := m.Called(req)
	return args.Error(0)
}

// MockUserUsecase is a mock implementation of UserUsecase
type MockUserUsecase struct {
	mock.Mock
}

func (m *MockUserUsecase) GetProfile(userID string) (*domain.User, error) {
	args := m.Called(userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserUsecase) UpdateProfile(userID string, req domain.UpdateProfileRequest) (*domain.User, error) {
	args := m.Called(userID, req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserUsecase) DeleteAccount(userID string) error {
	args := m.Called(userID)
	return args.Error(0)
}

func (m *MockUserUsecase) AddPushToken(userID string, req domain.PushTokenRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// MockGrammarUsecase is a mock implementation of GrammarUsecase
type MockGrammarUsecase struct {
	mock.Mock
}

func (m *MockGrammarUsecase) CheckGrammar(text string) (*models.GrammarResponse, error) {
	args := m.Called(text)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.GrammarResponse), args.Error(1)
}
