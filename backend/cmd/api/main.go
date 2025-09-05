package main

import (
	"log"
	"os"

	"github.com/joho/godotenv"
	_ "lissanai.com/backend/docs" // <-- add this for swagger
	"lissanai.com/backend/internal/server"
)

// @title           LissanAI API
// @version         1.0
// @description     AI-powered English coach for Ethiopians seeking global job opportunities
// @host           	localhost:8080
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	server := server.New()
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting LissanAI server on port %s", port)
	server.Run(":" + port)
}

//  lissan-ai-backend-dev.onrender.com
