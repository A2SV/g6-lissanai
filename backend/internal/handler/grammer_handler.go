package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/usecase"
)

type GrammarHandler struct {
	grammarUsecase *usecase.GrammarUsecase
}

func NewGrammarHandler(grammarUsecase *usecase.GrammarUsecase) *GrammarHandler {
	return &GrammarHandler{
		grammarUsecase: grammarUsecase,
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

	c.JSON(http.StatusOK, resp)
}
