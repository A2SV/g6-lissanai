// internal/domain/models.go
package domain

import (
	"time"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Auth requests
type RegisterRequest struct {
	Name     string `json:"name" binding:"required" example:"John Doe"`
	Email    string `json:"email" binding:"required,email" example:"john@lissanai.com"`
	Password string `json:"password" binding:"required,min=8" example:"strongpassword123"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"john@lissanai.com"`
	Password string `json:"password" binding:"required" example:"strongpassword123"`
}

type SocialAuthRequest struct {
	Provider     string `json:"provider" binding:"required" example:"google"`
	AccessToken  string `json:"access_token" binding:"required" example:"ya29.a0AfH6SMC..."`
	Name         string `json:"name,omitempty" example:"John Doe"`
	Email        string `json:"email,omitempty" example:"john@lissanai.com"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email" example:"john@lissanai.com"`
}

type ResetPasswordRequest struct {
	Token       string `json:"token" binding:"required" example:"reset_token_123"`
	NewPassword string `json:"new_password" binding:"required,min=8" example:"newstrongpassword123"`
}

type UpdateProfileRequest struct {
	Name     *string            `json:"name,omitempty" example:"John Updated"`
	Settings map[string]interface{} `json:"settings,omitempty"`
}

type PushTokenRequest struct {
	Token    string `json:"token" binding:"required" example:"fcm_token_123"`
	Platform string `json:"platform" binding:"required" example:"ios"`
}

// Responses
type AuthResponse struct {
	User         *User  `json:"user"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

type TokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int64  `json:"expires_in"`
}

type MessageResponse struct {
	Message string `json:"message"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

// User model
type User struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Name         string            `json:"name" bson:"name"`
	Email        string            `json:"email" bson:"email"`
	PasswordHash string            `json:"-" bson:"password_hash,omitempty"`
	Provider     string            `json:"provider,omitempty" bson:"provider,omitempty"`
	ProviderID   string            `json:"-" bson:"provider_id,omitempty"`
	Settings     map[string]interface{} `json:"settings,omitempty" bson:"settings,omitempty"`
	PushTokens   []PushToken       `json:"-" bson:"push_tokens,omitempty"`
	CreatedAt    time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at" bson:"updated_at"`
}

type PushToken struct {
	Token     string    `json:"token" bson:"token"`
	Platform  string    `json:"platform" bson:"platform"`
	CreatedAt time.Time `json:"created_at" bson:"created_at"`
}

type RefreshToken struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	UserID    primitive.ObjectID `bson:"user_id"`
	Token     string            `bson:"token"`
	ExpiresAt time.Time         `bson:"expires_at"`
	CreatedAt time.Time         `bson:"created_at"`
}

type PasswordReset struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	UserID    primitive.ObjectID `bson:"user_id"`
	Token     string            `bson:"token"`
	ExpiresAt time.Time         `bson:"expires_at"`
	CreatedAt time.Time         `bson:"created_at"`
	Used      bool              `bson:"used"`
}