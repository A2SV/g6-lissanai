// internal/usecase/auth_usecase.go
package usecase

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/repository"
	"lissanai.com/backend/internal/service"
)

type AuthUsecase interface {
	Register(req *domain.RegisterRequest) (*domain.AuthResponse, error)
	Login(req *domain.LoginRequest) (*domain.AuthResponse, error)
	SocialAuth(req *domain.SocialAuthRequest) (*domain.AuthResponse, error)
	Logout(userID primitive.ObjectID, refreshToken string) error
	RefreshToken(req *domain.RefreshTokenRequest) (*domain.TokenResponse, error)
	ForgotPassword(req *domain.ForgotPasswordRequest) error
	ResetPassword(req *domain.ResetPasswordRequest) error
}

type UserUsecase interface {
	GetProfile(userID primitive.ObjectID) (*domain.User, error)
	UpdateProfile(userID primitive.ObjectID, req *domain.UpdateProfileRequest) (*domain.User, error)
	DeleteAccount(userID primitive.ObjectID) error
	AddPushToken(userID primitive.ObjectID, req *domain.PushTokenRequest) error
}

type authUsecase struct {
	userRepo          repository.UserRepository
	refreshTokenRepo  repository.RefreshTokenRepository
	passwordResetRepo repository.PasswordResetRepository
	jwtService        service.JWTService
	passwordService   service.PasswordService
	emailService      service.EmailService
}

type userUsecase struct {
	userRepo         repository.UserRepository
	refreshTokenRepo repository.RefreshTokenRepository
}

func NewAuthUsecase(
	userRepo repository.UserRepository,
	refreshTokenRepo repository.RefreshTokenRepository,
	passwordResetRepo repository.PasswordResetRepository,
	jwtService service.JWTService,
	passwordService service.PasswordService,
	emailService service.EmailService,
) AuthUsecase {
	return &authUsecase{
		userRepo:          userRepo,
		refreshTokenRepo:  refreshTokenRepo,
		passwordResetRepo: passwordResetRepo,
		jwtService:        jwtService,
		passwordService:   passwordService,
		emailService:      emailService,
	}
}

func NewUserUsecase(
	userRepo repository.UserRepository,
	refreshTokenRepo repository.RefreshTokenRepository,
) UserUsecase {
	return &userUsecase{
		userRepo:         userRepo,
		refreshTokenRepo: refreshTokenRepo,
	}
}

func (u *authUsecase) Register(req *domain.RegisterRequest) (*domain.AuthResponse, error) {
	// Check if user already exists
	existingUser, _ := u.userRepo.GetUserByEmail(req.Email)
	if existingUser != nil {
		return nil, errors.New("user with this email already exists")
	}

	// Hash password
	hashedPassword, err := u.passwordService.HashPassword(req.Password)
	if err != nil {
		return nil, errors.New("failed to hash password")
	}

	// Create user
	newUser := &domain.User{
		Name:         req.Name,
		Email:        req.Email,
		PasswordHash: hashedPassword,
		Settings:     make(map[string]interface{}),
	}

	user, err := u.userRepo.CreateUser(newUser)
	if err != nil {
		return nil, errors.New("failed to create user")
	}

	return u.generateAuthResponse(user)
}

func (u *authUsecase) Login(req *domain.LoginRequest) (*domain.AuthResponse, error) {
	// Get user by email
	user, err := u.userRepo.GetUserByEmail(req.Email)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Check password
	if !u.passwordService.CheckPassword(req.Password, user.PasswordHash) {
		return nil, errors.New("invalid email or password")
	}

	return u.generateAuthResponse(user)
}

func (u *authUsecase) SocialAuth(req *domain.SocialAuthRequest) (*domain.AuthResponse, error) {
	// In a real implementation, you would validate the access token with the provider
	// For now, we'll assume the token is valid and extract user info

	// Try to find existing user by provider
	user, err := u.userRepo.GetUserByProviderID(req.Provider, req.AccessToken)
	if err != nil {
		// User doesn't exist, try to find by email
		if req.Email != "" {
			user, err = u.userRepo.GetUserByEmail(req.Email)
			if err != nil {
				// Create new user
				user = &domain.User{
					Name:       req.Name,
					Email:      req.Email,
					Provider:   req.Provider,
					ProviderID: req.AccessToken,
					Settings:   make(map[string]interface{}),
				}
				user, err = u.userRepo.CreateUser(user)
				if err != nil {
					return nil, errors.New("failed to create user")
				}
			} else {
				// Update existing user with provider info
				user.Provider = req.Provider
				user.ProviderID = req.AccessToken
				err = u.userRepo.UpdateUser(user)
				if err != nil {
					return nil, errors.New("failed to update user")
				}
			}
		} else {
			return nil, errors.New("email is required for social authentication")
		}
	}

	return u.generateAuthResponse(user)
}

func (u *authUsecase) Logout(userID primitive.ObjectID, refreshToken string) error {
	if refreshToken != "" {
		return u.refreshTokenRepo.DeleteRefreshToken(refreshToken)
	}
	return u.refreshTokenRepo.DeleteUserRefreshTokens(userID)
}

func (u *authUsecase) RefreshToken(req *domain.RefreshTokenRequest) (*domain.TokenResponse, error) {
	// Get refresh token from database
	refreshToken, err := u.refreshTokenRepo.GetRefreshToken(req.RefreshToken)
	if err != nil {
		return nil, errors.New("invalid refresh token")
	}

	// Check if token is expired
	if refreshToken.ExpiresAt.Before(time.Now()) {
		u.refreshTokenRepo.DeleteRefreshToken(req.RefreshToken)
		return nil, errors.New("refresh token expired")
	}

	// Generate new access token
	accessToken, err := u.jwtService.GenerateAccessToken(refreshToken.UserID)
	if err != nil {
		return nil, errors.New("failed to generate access token")
	}

	return &domain.TokenResponse{
		AccessToken: accessToken,
		ExpiresIn:   15 * 60, // 15 minutes
	}, nil
}

func (u *authUsecase) ForgotPassword(req *domain.ForgotPasswordRequest) error {
	// Check if user exists
	user, err := u.userRepo.GetUserByEmail(req.Email)
	if err != nil {
		// Don't reveal if email exists or not
		return nil
	}

	// Generate reset token
	resetToken := uuid.New().String()

	// Create password reset record
	passwordReset := &domain.PasswordReset{
		UserID:    user.ID,
		Token:     resetToken,
		ExpiresAt: time.Now().Add(1 * time.Hour), // 1 hour expiry
		Used:      false,
	}

	err = u.passwordResetRepo.CreatePasswordReset(passwordReset)
	if err != nil {
		return errors.New("failed to create password reset")
	}

	// Send password reset email
	err = u.emailService.SendPasswordResetEmail(user.Email, resetToken, user.Name)
	if err != nil {
		// Log the error but don't fail the request - user still gets success response
		// This prevents revealing whether email sending failed
		// In production, you might want to log this error for monitoring
		return nil
	}

	return nil
}

func (u *authUsecase) ResetPassword(req *domain.ResetPasswordRequest) error {
	// Get password reset record
	passwordReset, err := u.passwordResetRepo.GetPasswordReset(req.Token)
	if err != nil {
		return errors.New("invalid or expired reset token")
	}

	// Get user
	user, err := u.userRepo.GetUserByID(passwordReset.UserID)
	if err != nil {
		return errors.New("user not found")
	}

	// Hash new password
	hashedPassword, err := u.passwordService.HashPassword(req.NewPassword)
	if err != nil {
		return errors.New("failed to hash password")
	}

	// Update user password
	user.PasswordHash = hashedPassword
	err = u.userRepo.UpdateUser(user)
	if err != nil {
		return errors.New("failed to update password")
	}

	// Mark reset token as used
	err = u.passwordResetRepo.MarkPasswordResetUsed(req.Token)
	if err != nil {
		return errors.New("failed to mark reset token as used")
	}

	// Delete all refresh tokens for this user
	u.refreshTokenRepo.DeleteUserRefreshTokens(user.ID)

	return nil
}

func (u *authUsecase) generateAuthResponse(user *domain.User) (*domain.AuthResponse, error) {
	// Generate access token
	accessToken, err := u.jwtService.GenerateAccessToken(user.ID)
	if err != nil {
		return nil, errors.New("failed to generate access token")
	}

	// Generate refresh token
	refreshTokenString, err := u.jwtService.GenerateRefreshToken()
	if err != nil {
		return nil, errors.New("failed to generate refresh token")
	}

	// Save refresh token to database
	refreshToken := &domain.RefreshToken{
		UserID:    user.ID,
		Token:     refreshTokenString,
		ExpiresAt: time.Now().Add(7 * 24 * time.Hour), // 7 days
	}

	err = u.refreshTokenRepo.CreateRefreshToken(refreshToken)
	if err != nil {
		return nil, errors.New("failed to save refresh token")
	}

	// Remove sensitive data from user response
	userResponse := *user
	userResponse.PasswordHash = ""

	return &domain.AuthResponse{
		User:         &userResponse,
		AccessToken:  accessToken,
		RefreshToken: refreshTokenString,
		ExpiresIn:    15 * 60, // 15 minutes
	}, nil
}

// User Usecase Implementation
func (u *userUsecase) GetProfile(userID primitive.ObjectID) (*domain.User, error) {
	user, err := u.userRepo.GetUserByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}

	// Remove sensitive data
	user.PasswordHash = ""
	return user, nil
}

func (u *userUsecase) UpdateProfile(userID primitive.ObjectID, req *domain.UpdateProfileRequest) (*domain.User, error) {
	user, err := u.userRepo.GetUserByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}

	// Update fields if provided
	if req.Name != nil {
		user.Name = *req.Name
	}
	if req.Settings != nil {
		if user.Settings == nil {
			user.Settings = make(map[string]interface{})
		}
		for key, value := range req.Settings {
			user.Settings[key] = value
		}
	}

	err = u.userRepo.UpdateUser(user)
	if err != nil {
		return nil, errors.New("failed to update user")
	}

	// Remove sensitive data
	user.PasswordHash = ""
	return user, nil
}

func (u *userUsecase) DeleteAccount(userID primitive.ObjectID) error {
	// Delete all refresh tokens
	u.refreshTokenRepo.DeleteUserRefreshTokens(userID)

	// Delete user
	return u.userRepo.DeleteUser(userID)
}

func (u *userUsecase) AddPushToken(userID primitive.ObjectID, req *domain.PushTokenRequest) error {
	pushToken := domain.PushToken{
		Token:    req.Token,
		Platform: req.Platform,
	}

	return u.userRepo.AddPushToken(userID, pushToken)
}
