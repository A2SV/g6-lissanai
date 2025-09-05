package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/domain/entities"
	"lissanai.com/backend/internal/domain/interfaces"
)

// The struct and constructor remain the same.
type EmailController struct {
	emailUC interfaces.EmailUsecase
}

func NewEmailController(emailUC interfaces.EmailUsecase) *EmailController {
	return &EmailController{emailUC: emailUC}
}

// --- HANDLER #1: GENERATE EMAIL ---
// We adapt the Swagger comments from the old file for this new function.

// GenerateEmailHandler godoc
// @Summary      Generate a new email
// @Description  Generates a complete, professional email from a user's prompt (which can be in English or Amharic).
// @Tags         Email
// @Accept       json
// @Produce      json
// @Param        generateRequest  body      entities.GenerateEmailRequest  true  "The user's prompt and optional tone/template."
// @Success      200              {object}  entities.EmailResponse
// @Failure      400              {object}  object{error=string}
// @Failure      500              {object}  object{error=string}
// @Router       /email/generate [post]
func (ctrl *EmailController) GenerateEmailHandler(c *gin.Context) {
	var req entities.GenerateEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request: " + err.Error()})
		return
	}

	response, err := ctrl.emailUC.GenerateEmailFromPrompt(c.Request.Context(), &req)
	if err != nil {
		log.Printf("!!! INTERNAL SERVER ERROR (GenerateEmail): %v !!!", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate email"})
		return
	}

	c.JSON(http.StatusOK, response)
}

// --- HANDLER #2: EDIT EMAIL ---
// We create new Swagger comments for this new function.

// EditEmailHandler godoc
// @Summary      Edit an existing email
// @Description  Corrects and improves a user's drafted email to make it more professional.
// @Tags         Email
// @Accept       json
// @Produce      json
// @Param        editRequest  body      entities.EditEmailRequest  true  "The user's email draft and optional tone/template."
// @Success      200          {object}  entities.EmailResponse
// @Failure      400          {object}  object{error=string}
// @Failure      500          {object}  object{error=string}
// @Router       /email/edit [post]
func (ctrl *EmailController) EditEmailHandler(c *gin.Context) {
	var req entities.EditEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request: " + err.Error()})
		return
	}

	response, err := ctrl.emailUC.EditEmailDraft(c.Request.Context(), &req)
	if err != nil {
		log.Printf("!!! INTERNAL SERVER ERROR (EditEmail): %v !!!", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit email"})
		return
	}

	c.JSON(http.StatusOK, response)
}
