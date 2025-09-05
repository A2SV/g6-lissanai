package server

import (
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/service"
)

func SetupStreakRoutes(router *gin.RouterGroup, authMiddleware gin.HandlerFunc, db *mongo.Database) {
	// Initialize streak service
	streakService := service.NewStreakService(db)

	// Initialize streak handler
	streakHandler := handler.NewStreakHandler(streakService)

	// Set up routes with authentication
	streakRoutes := router.Group("/streak")
	streakRoutes.Use(authMiddleware)
	{
		streakRoutes.GET("/info", streakHandler.GetStreakInfo)
		streakRoutes.POST("/freeze", streakHandler.FreezeStreak)
		streakRoutes.POST("/activity", streakHandler.RecordActivity) // For manual testing
		streakRoutes.GET("/calendar", streakHandler.GetActivityCalendar) // GitHub-like activity calendar
	}
}