package server

import (
	"github.com/gin-gonic/gin" // <-- added
	"lissanai.com/backend/internal/domain/interfaces"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
)

// SetupEmailRoutes sets up the email generation endpoint
func SetupEmailRoutes(router *gin.RouterGroup) interfaces.EmailUsecase {
	// 1. Initialize the AI email service
	emailService, err := service.NewAIEmailService()
	if err != nil {
		panic(err) // fail fast if API key or client setup fails
	}

	// 2. Initialize the usecase
	emailUC := usecase.NewEmailUsecase(emailService)

	// 3. Initialize the controller
	emailController := handler.NewEmailController(emailUC)

	// 4. Define the route
	router.POST("/email/process", emailController.ProcessEmailHandler)

	return emailUC
}
