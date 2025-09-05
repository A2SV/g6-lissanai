// internal/handler/learning_handler.go
package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
)

type LearningHandler struct {
	learningUsecase usecase.LearningUsecase
	streakService   *service.StreakService
}

func NewLearningHandler(learningUsecase usecase.LearningUsecase, streakService *service.StreakService) *LearningHandler {
	return &LearningHandler{
		learningUsecase: learningUsecase,
		streakService:   streakService,
	}
}

// GetAllLearningPaths godoc
// @Summary Get all learning paths
// @Description Retrieve all available learning paths with user progress if enrolled
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {array} domain.LearningPathResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/paths [get]
func (h *LearningHandler) GetAllLearningPaths(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}
	paths, err := h.learningUsecase.GetAllLearningPaths(userOID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, paths)
}

// EnrollInPath godoc
// @Summary Enroll in a learning path
// @Description Enroll the authenticated user in a specific learning path
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Learning Path ID"
// @Success 200 {object} domain.SuccessResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 404 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/paths/{id}/enroll [post]
func (h *LearningHandler) EnrollInPath(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}

	pathID := c.Param("id")
	if pathID == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "path ID is required"})
		return
	}

	req := &domain.EnrollPathRequest{PathID: pathID}

	err = h.learningUsecase.EnrollInPath(userOID, req)
	if err != nil {
		if err.Error() == "learning path not found" {
			c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
			return
		}
		if err.Error() == "user already enrolled in this path" {
			c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse{Message: "successfully enrolled in learning path"})
}

// GetUserProgress godoc
// @Summary Get user progress for a learning path
// @Description Get the authenticated user's progress for a specific learning path
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Learning Path ID"
// @Success 200 {object} domain.ProgressResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 404 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/paths/{id}/progress [get]
func (h *LearningHandler) GetUserProgress(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}

	pathID := c.Param("id")
	if pathID == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "path ID is required"})
		return
	}

	progress, err := h.learningUsecase.GetUserProgress(userOID, pathID)
	if err != nil {
		if err.Error() == "user not enrolled in this path" {
			c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, progress)
}

// GetLesson godoc
// @Summary Get lesson content
// @Description Fetch the content for a specific lesson
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Lesson ID"
// @Success 200 {object} domain.LessonResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 403 {object} domain.ErrorResponse
// @Failure 404 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/lessons/{id} [get]
func (h *LearningHandler) GetLesson(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}

	lessonID := c.Param("id")
	if lessonID == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "lesson ID is required"})
		return
	}
	lesson, err := h.learningUsecase.GetLesson(userOID, lessonID)
	if err != nil {
		if err.Error() == "lesson not found" {
			c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
			return
		}
		if err.Error() == "user not enrolled in this learning path" {
			c.JSON(http.StatusForbidden, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, lesson)
}

// CompleteLesson godoc
// @Summary Mark lesson as completed
// @Description Mark a lesson as completed for the authenticated user
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Lesson ID"
// @Success 200 {object} domain.SuccessResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 403 {object} domain.ErrorResponse
// @Failure 404 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/lessons/{id}/complete [post]
func (h *LearningHandler) CompleteLesson(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}

	lessonID := c.Param("id")
	if lessonID == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "lesson ID is required"})
		return
	}

	req := &domain.CompleteLessonRequest{LessonID: lessonID}

	err = h.learningUsecase.CompleteLesson(userOID, req)
	if err != nil {
		if err.Error() == "lesson not found" {
			c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
			return
		}
		if err.Error() == "user not enrolled in this learning path" {
			c.JSON(http.StatusForbidden, domain.ErrorResponse{Error: err.Error()})
			return
		}
		if err.Error() == "lesson already completed" {
			c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	// Record streak activity for lesson completion
	if err := h.streakService.RecordActivity(c.Request.Context(), userOID, "lesson_completed"); err != nil {
		log.Printf("Failed to record streak activity for user %s: %v", userOID.Hex(), err)
		// Don't fail the request if streak recording fails
	}

	c.JSON(http.StatusOK, domain.SuccessResponse{Message: "lesson marked as completed! 🔥"})
}

// SubmitQuiz godoc
// @Summary Submit quiz answers
// @Description Submit user's answers to a quiz for grading
// @Tags Learning
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Quiz ID"
// @Param request body domain.QuizSubmissionRequest true "Quiz answers"
// @Success 200 {object} domain.QuizResultResponse
// @Failure 400 {object} domain.ErrorResponse
// @Failure 401 {object} domain.ErrorResponse
// @Failure 403 {object} domain.ErrorResponse
// @Failure 404 {object} domain.ErrorResponse
// @Failure 500 {object} domain.ErrorResponse
// @Router /api/v1/learning/quizzes/{id}/submit [post]
func (h *LearningHandler) SubmitQuiz(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, domain.ErrorResponse{Error: "user not authenticated"})
		return
	}

	userOID, err := primitive.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "invalid user ID"})
		return
	}

	quizID := c.Param("id")
	if quizID == "" {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: "quiz ID is required"})
		return
	}

	var req domain.QuizSubmissionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponse{Error: err.Error()})
		return
	}

	// Set quiz ID from URL parameter
	req.QuizID = quizID

	result, err := h.learningUsecase.SubmitQuiz(userOID, &req)
	if err != nil {
		if err.Error() == "quiz not found" {
			c.JSON(http.StatusNotFound, domain.ErrorResponse{Error: err.Error()})
			return
		}
		if err.Error() == "user not enrolled in this learning path" {
			c.JSON(http.StatusForbidden, domain.ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, domain.ErrorResponse{Error: err.Error()})
		return
	}

	// Record streak activity if quiz was passed
	if result.Passed {
		if err := h.streakService.RecordActivity(c.Request.Context(), userOID, "quiz_passed"); err != nil {
			log.Printf("Failed to record streak activity for user %s: %v", userOID.Hex(), err)
			// Don't fail the request if streak recording fails
		}
	}

	c.JSON(http.StatusOK, result)
}