// internal/server/server.go
package server

import (
	"log"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"lissanai.com/backend/internal/database"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/middleware"
	"lissanai.com/backend/internal/repository"
	"lissanai.com/backend/internal/service"
	"lissanai.com/backend/internal/usecase"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	_ "lissanai.com/backend/docs"
)

func New() *gin.Engine {
	router := gin.Default()

	// --- CORS Middleware ---
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // Replace "*" with your frontend URL in production
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// --- Database Connection ---
	db, err := database.NewMongoConnection()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// --- Services ---
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "your-secret-key-change-this-in-production" // Default for development
		log.Println("Warning: Using default JWT secret. Set JWT_SECRET environment variable in production.")
	}

	jwtService := service.NewJWTService(jwtSecret)
	passwordService := service.NewPasswordService()
	apiKey := os.Getenv("GEMINI_API_KEY")
	emailService := service.NewEmailService()

	// Create the AI service.
	aiService, err := service.NewAiService()
	if err != nil {
		log.Fatal(err)
	}
	chatAiService, _ := service.NewChatAiService(apiKey)

	// --- Repositories ---
	userRepo := repository.NewUserRepository(db)
	refreshTokenRepo := repository.NewRefreshTokenRepository(db)
	passwordResetRepo := repository.NewPasswordResetRepository(db)
	chatSessionRepo := repository.NewMongoSessionRepo(db)
	chatMessageRepo := repository.NewMongoMessageRepo(db)
	learningRepo := repository.NewLearningRepository(db)

	// --- Use Cases ---
	authUsecase := usecase.NewAuthUsecase(userRepo, refreshTokenRepo, passwordResetRepo, jwtService, passwordService, emailService)
	userUsecase := usecase.NewUserUsecase(userRepo, refreshTokenRepo)
	grammer_usecase := usecase.NewGrammarUsecase(aiService)
	chat_usecase := usecase.NewChatUsecase(chatSessionRepo, chatMessageRepo, chatAiService)
	learningUsecase := usecase.NewLearningUsecase(learningRepo)

	// --- Services ---
	streakService := service.NewStreakService(db)
	
	// --- Background Jobs ---
	// Note: In production, you might want to start these jobs in a separate process
	// For now, we'll start them here for simplicity

	// --- Handlers ---
	authHandler := handler.NewAuthHandler(authUsecase)
	userHandler := handler.NewUserHandler(userUsecase)
	grammer_handler := handler.NewGrammarHandler(grammer_usecase, streakService)
	chat_handler := handler.NewChatHandler(chat_usecase, streakService)
	pronunciationHandler := handler.NewPronunciationActivityHandler(streakService)
	learningHandler := handler.NewLearningHandler(learningUsecase, streakService)

	// --- Middleware ---
	authMiddleware := middleware.AuthMiddleware(jwtService)

	// --- Routes ---
	apiV1 := router.Group("/api/v1")
	{
		// Auth routes (public)
		auth := apiV1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/social", authHandler.SocialAuth)
			auth.POST("/refresh", authHandler.RefreshToken)
			auth.POST("/forgot-password", authHandler.ForgotPassword)
			auth.POST("/reset-password", authHandler.ResetPassword)

			// Protected auth routes
			auth.POST("/logout", authMiddleware, authHandler.Logout)
		}

		grammar := apiV1.Group("/grammar/check")
		{
			grammar.POST("/", authMiddleware, grammer_handler.GrammarCheck)
		}

		// --- Chat/Interview routes ---
		chatAPI := apiV1.Group("/interview")
		{
			chatAPI.POST("/start", authMiddleware, chat_handler.StartSessionHandler)
			chatAPI.GET("/question", authMiddleware, chat_handler.GetNextQuestionHandler)
			chatAPI.POST("/answer", authMiddleware, chat_handler.SubmitAnswerHandler)
			chatAPI.POST("/:session_id/end", authMiddleware, chat_handler.EndSessionHandler)

		}

		// User routes (protected)
		users := apiV1.Group("/users")
		users.Use(authMiddleware)
		{
			users.GET("/me", userHandler.GetProfile)
			users.PATCH("/me", userHandler.UpdateProfile)
			users.DELETE("/me", userHandler.DeleteAccount)
			users.POST("/me/push-token", userHandler.AddPushToken)
		}

		// Email routes (protected)
		emailGroup := apiV1.Group("/")
		SetupEmailRoutes(emailGroup)

		// Learning routes (protected)
		learningRoutes := apiV1.Group("/learning")
		learningRoutes.Use(authMiddleware)
		{
			// Learning paths
			learningRoutes.GET("/paths", learningHandler.GetAllLearningPaths)
			learningRoutes.POST("/paths/:id/enroll", learningHandler.EnrollInPath)
			learningRoutes.GET("/paths/:id/progress", learningHandler.GetUserProgress)

			// Lessons
			learningRoutes.GET("/lessons/:id", learningHandler.GetLesson)
			learningRoutes.POST("/lessons/:id/complete", learningHandler.CompleteLesson)

			// Quizzes
			learningRoutes.POST("/quizzes/:id/submit", learningHandler.SubmitQuiz)
		}

		// Free Speaking route
		SetupSpeakingRoutes(apiV1)
		SetupPronunciationRoutes(apiV1)

		// Pronunciation routes (protected)
		pronunciationRoutes := apiV1.Group("/pronunciation")
		pronunciationRoutes.Use(authMiddleware)
		{
			pronunciationRoutes.POST("/activity", pronunciationHandler.RecordPronunciationActivity)
		}

		// Streak routes (protected)
		SetupStreakRoutes(apiV1, authMiddleware, db)
	}

	// --- Swagger ---
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	return router
}
