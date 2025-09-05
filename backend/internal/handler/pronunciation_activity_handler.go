package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/service"
)

type PronunciationActivityHandler struct {
	streakService *service.StreakService
}

func NewPronunciationActivityHandler(streakService *service.StreakService) *PronunciationActivityHandler {
	return &PronunciationActivityHandler{
		streakService: streakService,
	}
}

// @Summary Record pronunciation practice activity
// @Description Record that a user completed a pronunciation practice session for streak tracking
// @Tags Pronunciation
// @Accept json
// @Produce json
// @Param request body map[string]interface{} false "Pronunciation session data"
// @Success 200 {object} domain.SuccessResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Security BearerAuth
// @Router /api/v1/pronunciation/activity [post]
func (h *PronunciationActivityHandler) RecordPronunciationActivity(c *gin.Context) {
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

	// Record streak activity for pronunciation session
	if err := h.streakService.RecordActivity(c.Request.Context(), objectID, "pronunciation_session"); err != nil {
		log.Printf("Failed to record streak activity for user %s: %v", objectID.Hex(), err)
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: "Failed to record activity"})
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse{Message: "Pronunciation practice recorded! 🔥"})
}