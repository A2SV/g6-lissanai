package server

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"lissanai.com/backend/internal/client"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/service"
)

func SetupSpeakingRoutes(router *gin.RouterGroup) {
	godotenv.Load() // optional .env

	groqAPIKey := os.Getenv("GROQ_API_KEY")
	hfAPIKey := os.Getenv("HF_API_KEY")
	// 1. Use the new environment variable names for Unreal Speech
	unrealSpeechKey := os.Getenv("UNREAL_SPEECH_API_KEY")
	voiceID := os.Getenv("UNREAL_SPEECH_VOICE_ID")

	// 2. Update the check to look for the new keys
	if groqAPIKey == "" || hfAPIKey == "" || unrealSpeechKey == "" || voiceID == "" {
		log.Fatal("Missing one or more API keys or voice ID")
	}

	groqClient := client.NewGroqClient(groqAPIKey)
	whisperClient := client.NewWhisperClient(hfAPIKey)
	// 3. Create an instance of our new Unreal Speech client
	unrealSpeechClient := client.NewUnrealSpeechTTSClient(unrealSpeechKey, voiceID)

    // 4. Pass the new client into the service constructor
	speakingService := service.NewSpeakingService(groqClient, whisperClient, unrealSpeechClient)
	conversationHandler := handler.NewConversationHandler(speakingService)

	router.GET("/ws/conversation", conversationHandler.HandleConversation)
}