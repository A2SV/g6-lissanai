// handler/email_handler.go (assuming file name)

package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/domain/entities"
	"lissanai.com/backend/internal/domain/interfaces"
)

type EmailController struct {
	emailUC interfaces.EmailUsecase
}

func NewEmailController(emailUC interfaces.EmailUsecase) *EmailController {
	return &EmailController{emailUC: emailUC}
}

// ProcessEmailHandler godoc
// @Summary      Process Email Request
// @Description  Generates a new email or edits an existing one using AI. Set the 'type' field in the request body to 'GENERATE' or 'EDIT'.
//               Set the 'type' field to:
//               - "GENERATE": generates a full email
//               - "EDIT": improves an existing email
// @Tags         Email
// @Accept       json
// @Produce      json
// @Param        emailRequest  body      entities.EmailRequest  true  "The user's request, including the type (GENERATE/EDIT), prompt, and optional tone."
// @Success      200           {object}  entities.EmailResponse
// @Failure      400           {object}  object{error=string}
// @Failure      500           {object}  object{error=string}
// @Router       /email/process [post]
func (c *EmailController) ProcessEmailHandler(ctx *gin.Context) {
	var req entities.EmailRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// NOTE: It is better to use the gin context rather than creating a new background context.
	// This allows for better request scoping, cancellation, and tracing.
	emailResp, err := c.emailUC.GenerateProfessionalEmail(ctx.Request.Context(), &req)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, emailResp)
}