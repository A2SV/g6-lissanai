package server

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	// "lissanai.com/backend/internal/domain/interfaces"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"
)

// SetupEmailRoutes initializes and registers all routes for the email feature.
func SetupEmailRoutes(router *gin.RouterGroup) { // Note: Removed the return value, it's not needed.
	// 1. Initialize the AI email service
	geminiAPIKey := os.Getenv("GEMINI_API_KEY")
	if geminiAPIKey == "" {
		log.Fatal("FATAL ERROR: GEMINI_API_KEY is not set in your .env file.")
	}
	log.Println("Successfully loaded GEMINI_API_KEY.")
	// You should add a check here to ensure the key is not empty
	emailService, err := service.NewAIEmailService(geminiAPIKey, "gemini-1.5-flash-latest") // Changed to gemini-pro for cost/speed
	if err != nil {
		panic(err)
	}

	// 2. Initialize the usecase
	emailUC := usecase.NewEmailUsecase(emailService)

	// 3. Initialize the controller
	emailController := handler.NewEmailController(emailUC)

	// 4. Define the routes within an /email group for organization
	emailRoutes := router.Group("/email")
	{
		emailRoutes.POST("/generate", emailController.GenerateEmailHandler)
		emailRoutes.POST("/edit", emailController.EditEmailHandler)
	}
}
