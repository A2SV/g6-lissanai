package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain/models"
	"lissanai.com/backend/internal/middleware"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
)

type ChatHandler struct {
	usecase       *usecase.ChatUsecase
	streakService *service.StreakService
}

func NewChatHandler(u *usecase.ChatUsecase, streakService *service.StreakService) *ChatHandler {
	return &ChatHandler{
		usecase:       u,
		streakService: streakService,
	}
}

// StartSessionHandler creates a new interview session
// @Summary Start a new interview session
// @Description Creates a new interview session for the authenticated user
// @Tags Interview
// @Accept json
// @Produce json
// @Success 200 {object} models.SessionReturn
// @Failure 401 {object} models.ErrorResponse "Unauthorized"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Security BearerAuth
// @Router /interview/start [post]
func (h *ChatHandler) StartSessionHandler(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	session, err := h.usecase.StartSession(userID.Hex())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, session)
}

// GetNextQuestionHandler returns the next question
// @Summary Get the next interview question
// @Description Retrieves the next question for the current session
// @Tags Interview
// @Produce json
// @Param session_id query string true "Session ID"
// @Success 200 {object} models.NextQuestionReturn "Next question returned"
// @Failure 400 {object} models.ErrorResponse "Bad request"
// @Security BearerAuth
// @Router /interview/question [get]
func (h *ChatHandler) GetNextQuestionHandler(c *gin.Context) {
	sessionID := c.Query("session_id")
	if sessionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "session_id is required"})
		return
	}

	question, err := h.usecase.GetNextQuestion(sessionID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, question)
}

// SubmitAnswerHandler receives user's answer and returns feedback
// @Summary Submit user's answer
// @Description Submit an answer for the current session question
// @Tags Interview
// @Accept json
// @Produce json
// @Param input body models.SubmitAnswerRequest true "Answer input"
// @Success 200 {object} models.Feedback "Answer submitted successfully"
// @Failure 400 {object} models.ErrorResponse "Bad request"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Security BearerAuth
// @Router /interview/answer [post]
func (h *ChatHandler) SubmitAnswerHandler(c *gin.Context) {
	var req models.SubmitAnswerRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	msg, err := h.usecase.SubmitAnswer(req.SessionID, req.Answer)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Record streak activity for mock interview session
	if userID, exists := c.Get("user_id"); exists {
		if objectID, err := primitive.ObjectIDFromHex(userID.(string)); err == nil {
			if err := h.streakService.RecordActivity(c.Request.Context(), objectID, "mock_interview"); err != nil {
				log.Printf("Failed to record streak activity for user %s: %v", objectID.Hex(), err)
				// Don't fail the request if streak recording fails
			}
		}
	}

	c.JSON(http.StatusOK, msg)
}

// EndSessionHandler returns the final session summary
// @Summary End an interview session
// @Description Ends the session and returns the final summary
// @Tags Interview
// @Produce json
// @Param session_id path string true "Session ID"
// @Success 200 {object} models.SessionSummary "Session summary returned"
// @Failure 400 {object} models.ErrorResponse "Bad request"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Security BearerAuth
// @Router /interview/{session_id}/end [post]
func (h *ChatHandler) EndSessionHandler(c *gin.Context) {
	sessionID := c.Param("session_id")
	if sessionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "session_id is required"})
		return
	}

	summary, err := h.usecase.EndSession(sessionID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, summary)
}
