// internal/handler/auth_handler.go
package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/middleware"
	"lissanai.com/backend/internal/usecase"
)

type AuthHandler struct {
	authUsecase usecase.AuthUsecase
}

type UserHandler struct {
	userUsecase usecase.UserUsecase
}

func NewAuthHandler(authUsecase usecase.AuthUsecase) *AuthHandler {
	return &AuthHandler{authUsecase: authUsecase}
}

func NewUserHandler(userUsecase usecase.UserUsecase) *UserHandler {
	return &UserHandler{userUsecase: userUsecase}
}

// Register godoc
// @Summary      Register a new user
// @Description  Creates a new user account with email and password
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        userInfo body domain.RegisterRequest true "User Registration Information"
// @Success      201 {object} domain.AuthResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      409 {object} domain.ErrorResponse
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req domain.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	response, err := h.authUsecase.Register(&req)
	if err != nil {
		if err.Error() == "user with this email already exists" {
			c.JSON(http.StatusConflict, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, response)
}

// Login godoc
// @Summary      Login user
// @Description  Authenticate user with email and password
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        credentials body domain.LoginRequest true "User Login Credentials"
// @Success      200 {object} domain.AuthResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req domain.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	response, err := h.authUsecase.Login(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// SocialAuth godoc
// @Summary      Social authentication
// @Description  Authenticate or register user using social providers (Google, Apple)
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        socialInfo body domain.SocialAuthRequest true "Social Authentication Information"
// @Success      200 {object} domain.AuthResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Router       /auth/social [post]
func (h *AuthHandler) SocialAuth(c *gin.Context) {
	var req domain.SocialAuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	response, err := h.authUsecase.SocialAuth(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// Logout godoc
// @Summary      Logout user
// @Description  Invalidate user's session token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        refreshToken body domain.RefreshTokenRequest false "Refresh Token (optional)"
// @Success      200 {object} domain.MessageResponse
// @Failure      401 {object} domain.ErrorResponse
// @Security     BearerAuth
// @Router       /auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	var req domain.RefreshTokenRequest
	c.ShouldBindJSON(&req) // Optional refresh token

	err := h.authUsecase.Logout(userID, req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.MessageResponse{Message: "Successfully logged out"})
}

// RefreshToken godoc
// @Summary      Refresh access token
// @Description  Use refresh token to get a new access token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        refreshToken body domain.RefreshTokenRequest true "Refresh Token"
// @Success      200 {object} domain.TokenResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Router       /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req domain.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	response, err := h.authUsecase.RefreshToken(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// ForgotPassword godoc
// @Summary      Request password reset
// @Description  Send password reset link to user's email
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        email body domain.ForgotPasswordRequest true "User Email"
// @Success      200 {object} domain.MessageResponse
// @Failure      400 {object} domain.ErrorResponse
// @Router       /auth/forgot-password [post]
func (h *AuthHandler) ForgotPassword(c *gin.Context) {
	var req domain.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	err := h.authUsecase.ForgotPassword(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.MessageResponse{Message: "Password reset link sent to your email"})
}

// ResetPassword godoc
// @Summary      Reset password
// @Description  Set new password using reset token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        resetInfo body domain.ResetPasswordRequest true "Password Reset Information"
// @Success      200 {object} domain.MessageResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Router       /auth/reset-password [post]
func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req domain.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	err := h.authUsecase.ResetPassword(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.MessageResponse{Message: "Password reset successfully"})
}

// GetProfile godoc
// @Summary      Get user profile
// @Description  Get the profile of the authenticated user
// @Tags         Users
// @Produce      json
// @Success      200 {object} domain.User
// @Failure      401 {object} domain.ErrorResponse
// @Failure      404 {object} domain.ErrorResponse
// @Security     BearerAuth
// @Router       /users/me [get]
func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	user, err := h.userUsecase.GetProfile(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, user)
}

// UpdateProfile godoc
// @Summary      Update user profile
// @Description  Update parts of the user's profile (name, settings)
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        profileInfo body domain.UpdateProfileRequest true "Profile Update Information"
// @Success      200 {object} domain.User
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Failure      404 {object} domain.ErrorResponse
// @Security     BearerAuth
// @Router       /users/me [patch]
func (h *UserHandler) UpdateProfile(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	var req domain.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	user, err := h.userUsecase.UpdateProfile(userID, &req)
	if err != nil {
		c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, user)
}

// DeleteAccount godoc
// @Summary      Delete user account
// @Description  Allow a user to delete their account
// @Tags         Users
// @Produce      json
// @Success      200 {object} domain.MessageResponse
// @Failure      401 {object} domain.ErrorResponse
// @Failure      404 {object} domain.ErrorResponse
// @Security     BearerAuth
// @Router       /users/me [delete]
func (h *UserHandler) DeleteAccount(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	err := h.userUsecase.DeleteAccount(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.MessageResponse{Message: "Account deleted successfully"})
}

// AddPushToken godoc
// @Summary      Register push token
// @Description  Register a device token (FCM/APNs) for push notifications
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        tokenInfo body domain.PushTokenRequest true "Push Token Information"
// @Success      200 {object} domain.MessageResponse
// @Failure      400 {object} domain.ErrorResponse
// @Failure      401 {object} domain.ErrorResponse
// @Security     BearerAuth
// @Router       /users/me/push-token [post]
func (h *UserHandler) AddPushToken(c *gin.Context) {
	userID, exists := middleware.GetUserIDFromContext(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	var req domain.PushTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	err := h.userUsecase.AddPushToken(userID, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.MessageResponse{Message: "Push token registered successfully"})
}
