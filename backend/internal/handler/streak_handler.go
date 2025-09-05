package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/service"
)

type StreakHandler struct {
	streakService *service.StreakService
}

func NewStreakHandler(streakService *service.StreakService) *StreakHandler {
	return &StreakHandler{
		streakService: streakService,
	}
}

// @Summary Get user streak information
// @Description Get the current user's streak information including current streak, longest streak, and freeze status
// @Tags Streak
// @Produce json
// @Success 200 {object} domain.StreakInfo
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Security BearerAuth
// @Router /api/v1/streak/info [get]
func (h *StreakHandler) GetStreakInfo(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "User not authenticated"})
		return
	}

	objectID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	streakInfo, err := h.streakService.GetStreakInfo(c.Request.Context(), objectID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: "Failed to get streak information"})
		return
	}

	c.JSON(http.StatusOK, streakInfo)
}

// @Summary Freeze streak
// @Description Freeze the user's current streak to prevent it from being lost due to inactivity (limited uses per month)
// @Tags Streak
// @Accept json
// @Produce json
// @Param request body domain.FreezeStreakRequest false "Freeze reason"
// @Success 200 {object} domain.SuccessResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Security BearerAuth
// @Router /api/v1/streak/freeze [post]
func (h *StreakHandler) FreezeStreak(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "User not authenticated"})
		return
	}

	objectID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	var req domain.FreezeStreakRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// Reason is optional, so we don't fail if binding fails
		req.Reason = "No reason provided"
	}

	err = h.streakService.FreezeStreak(c.Request.Context(), objectID, req.Reason)
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse{Message: "Streak frozen successfully! 🧊"})
}

// @Summary Record activity (Internal)
// @Description Record a user activity to maintain their streak - this is called internally by other services
// @Tags Streak
// @Accept json
// @Produce json
// @Param activity_type query string true "Type of activity" Enums(lesson_completed, quiz_passed, daily_goal_met)
// @Success 200 {object} domain.SuccessResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Security BearerAuth
// @Router /api/v1/streak/activity [post]
func (h *StreakHandler) RecordActivity(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "User not authenticated"})
		return
	}

	objectID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	activityType := c.Query("activity_type")
	if activityType == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Activity type is required"})
		return
	}

	// Validate activity type
	validTypes := map[string]bool{
		"lesson_completed":       true,
		"quiz_passed":           true,
		"daily_goal_met":        true,
		"pronunciation_session": true,
		"mock_interview":        true,
		"grammar_check":         true,
	}

	if !validTypes[activityType] {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Invalid activity type"})
		return
	}

	err = h.streakService.RecordActivity(c.Request.Context(), objectID, activityType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: "Failed to record activity"})
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse{Message: "Activity recorded successfully! 🔥"})
}

// @Summary Get activity calendar
// @Description Get GitHub-like activity calendar showing daily learning activities
// @Tags Streak
// @Produce json
// @Param year query int false "Year (default: current year)" example(2025)
// @Success 200 {object} domain.ActivityCalendarResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Security BearerAuth
// @Router /api/v1/streak/calendar [get]
func (h *StreakHandler) GetActivityCalendar(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "User not authenticated"})
		return
	}

	objectID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "Invalid user ID"})
		return
	}

	// Get year parameter (default to current year)
	year := 0
	if yearStr := c.Query("year"); yearStr != "" {
		if parsedYear, err := strconv.Atoi(yearStr); err == nil {
			year = parsedYear
		}
	}

	calendar, err := h.streakService.GetActivityCalendar(c.Request.Context(), objectID, year)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: "Failed to get activity calendar"})
		return
	}

	c.JSON(http.StatusOK, calendar)
}