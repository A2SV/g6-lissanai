package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
)

type GrammarHandler struct {
	grammarUsecase *usecase.GrammarUsecase
	streakService  *service.StreakService
}

func NewGrammarHandler(grammarUsecase *usecase.GrammarUsecase, streakService *service.StreakService) *GrammarHandler {
	return &GrammarHandler{
		grammarUsecase: grammarUsecase,
		streakService:  streakService,
	}
}

// GrammarRequest defines the request body for grammar checking.
type GrammarRequest struct {
	Text string `json:"text" binding:"required" example:"he have two cats"`
}

// GrammarCheck godoc
// @Summary      Check Grammar
// @Description  Analyzes text for grammatical errors and returns corrections and explanations.
// @Tags         Grammar
// @Accept       json
// @Produce      json
// @Param        text body GrammarRequest true "Text to be checked"
// @Success      200 {object} models.GrammarResponse "Returns corrected text and explanation"
// @Failure      400 {object} object{error=string}
// @Failure      500 {object} object{error=string}
// @Security BearerAuth
// @Router       /grammar/check [post]
func (h *GrammarHandler) GrammarCheck(c *gin.Context) {
	var request GrammarRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request: " + err.Error()})
		return
	}

	resp, err := h.grammarUsecase.CheckGrammar(request.Text)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Record streak activity for grammar check
	if userID, exists := c.Get("user_id"); exists {
		if objectID, err := primitive.ObjectIDFromHex(userID.(string)); err == nil {
			if err := h.streakService.RecordActivity(c.Request.Context(), objectID, "grammar_check"); err != nil {
				log.Printf("Failed to record streak activity for user %s: %v", objectID.Hex(), err)
				// Don't fail the request if streak recording fails
			}
		}
	}

	c.JSON(http.StatusOK, resp)
}
