// cmd/api/main.go
package main

import (
	"log"
	"os"
	
	"github.com/joho/godotenv"
	"lissanai.com/backend/internal/server"
)

// @title           LissanAI Professional API
// @version         1.0
// @description     AI-powered English coach for Ethiopians seeking global job opportunities
// @host            lissan-ai-backend-dev.onrender.com
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.
func main() {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	server := server.New()
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default to 8080 if the PORT environment variable is not set
	}
	
	log.Printf("Starting LissanAI server on port %s", port)
	server.Run(":" + port)
}
