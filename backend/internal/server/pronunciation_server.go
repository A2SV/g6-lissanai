// In file: internal/server/pronunciation_server.go
package server

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/usecase"
)

func SetupPronunciationRoutes(router *gin.RouterGroup) {
	geminiAPIKey := os.Getenv("GEMINI_API_KEY")
	if geminiAPIKey == "" {
		log.Fatal("FATAL: GEMINI_API_KEY is not set.")
	}

	// We no longer create a genai.Client here.
	// We pass the API key string directly to the usecase.
	pronunciationUC := usecase.NewPronunciationUsecase(geminiAPIKey)

	// The rest of the setup is the same.
	pronunciationHandler := handler.NewPronunciationHandler(pronunciationUC)

	pronunciationRoutes := router.Group("/pronunciation")
	{
		pronunciationRoutes.GET("/sentence", pronunciationHandler.GetSentences)
		pronunciationRoutes.POST("/assess", pronunciationHandler.AssessPronunciation)
	}
}
