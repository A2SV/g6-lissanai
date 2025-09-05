// internal/domain/models.go
package domain

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

// Auth requests
type RegisterRequest struct {
	Name     string `json:"name" binding:"required" example:"John Doe"`
	Email    string `json:"email" binding:"required,email" example:"john@lissanai.com"`
	Password string `json:"password" binding:"required,min=8" example:"strongpassword123"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"john@lissanai.com"`
	Password string `json:"password" binding:"required" example:"strongpassword123"`
}

type SocialAuthRequest struct {
	Provider    string `json:"provider" binding:"required" example:"google"`
	AccessToken string `json:"access_token" binding:"required" example:"ya29.a0AfH6SMC..."`
	Name        string `json:"name,omitempty" example:"John Doe"`
	Email       string `json:"email,omitempty" example:"john@lissanai.com"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email" example:"john@lissanai.com"`
}

type ResetPasswordRequest struct {
	Token       string `json:"token" binding:"required" example:"reset_token_123"`
	NewPassword string `json:"new_password" binding:"required,min=8" example:"newstrongpassword123"`
}

type UpdateProfileRequest struct {
	Name     *string                `json:"name,omitempty" example:"John Updated"`
	Settings map[string]interface{} `json:"settings,omitempty"`
}

type PushTokenRequest struct {
	Token    string `json:"token" binding:"required" example:"fcm_token_123"`
	Platform string `json:"platform" binding:"required" example:"ios"`
}

// Responses
type AuthResponse struct {
	User         *User  `json:"user"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

type TokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int64  `json:"expires_in"`
}

type MessageResponse struct {
	Message string `json:"message"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

// User model
type User struct {
	ID           primitive.ObjectID     `json:"id" bson:"_id,omitempty"`
	Name         string                 `json:"name" bson:"name"`
	Email        string                 `json:"email" bson:"email"`
	PasswordHash string                 `json:"-" bson:"password_hash,omitempty"`
	Provider     string                 `json:"provider,omitempty" bson:"provider,omitempty"`
	ProviderID   string                 `json:"-" bson:"provider_id,omitempty"`
	Settings     map[string]interface{} `json:"settings,omitempty" bson:"settings,omitempty"`
	PushTokens   []PushToken            `json:"-" bson:"push_tokens,omitempty"`
	
	// Streak System
	CurrentStreak    int       `json:"current_streak" bson:"current_streak"`
	LongestStreak    int       `json:"longest_streak" bson:"longest_streak"`
	LastActivityDate time.Time `json:"last_activity_date" bson:"last_activity_date"`
	StreakFrozen     bool      `json:"streak_frozen" bson:"streak_frozen"`
	FreezeCount      int       `json:"freeze_count" bson:"freeze_count"`
	
	CreatedAt    time.Time              `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time              `json:"updated_at" bson:"updated_at"`
}

type PushToken struct {
	Token     string    `json:"token" bson:"token"`
	Platform  string    `json:"platform" bson:"platform"`
	CreatedAt time.Time `json:"created_at" bson:"created_at"`
}

type RefreshToken struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	UserID    primitive.ObjectID `bson:"user_id"`
	Token     string             `bson:"token"`
	ExpiresAt time.Time          `bson:"expires_at"`
	CreatedAt time.Time          `bson:"created_at"`
}

type PasswordReset struct {
	ID        primitive.ObjectID `bson:"_id,omitempty"`
	UserID    primitive.ObjectID `bson:"user_id"`
	Token     string             `bson:"token"`
	ExpiresAt time.Time          `bson:"expires_at"`
	CreatedAt time.Time          `bson:"created_at"`
	Used      bool               `bson:"used"`
}

// Learning Path Models
type LearningPath struct {
	ID          primitive.ObjectID   `json:"id" bson:"_id,omitempty"`
	Title       string               `json:"title" bson:"title"`
	Description string               `json:"description" bson:"description"`
	Level       string               `json:"level" bson:"level"` // beginner, intermediate, advanced
	Category    string               `json:"category" bson:"category"`
	Duration    int                  `json:"duration" bson:"duration"` // in minutes
	LessonIDs   []primitive.ObjectID `json:"lesson_ids" bson:"lesson_ids"`
	CreatedAt   time.Time            `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time            `json:"updated_at" bson:"updated_at"`
}

type Lesson struct {
	ID          primitive.ObjectID  `json:"id" bson:"_id,omitempty"`
	PathID      primitive.ObjectID  `json:"path_id" bson:"path_id"`
	Title       string              `json:"title" bson:"title"`
	Description string              `json:"description" bson:"description"`
	Content     string              `json:"content" bson:"content"`
	Type        string              `json:"type" bson:"type"` // video, text, quiz, exercise
	Duration    int                 `json:"duration" bson:"duration"` // in minutes
	Order       int                 `json:"order" bson:"order"`
	QuizID      *primitive.ObjectID `json:"quiz_id,omitempty" bson:"quiz_id,omitempty"`
	CreatedAt   time.Time           `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time           `json:"updated_at" bson:"updated_at"`
}

type Quiz struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	LessonID  primitive.ObjectID `json:"lesson_id" bson:"lesson_id"`
	Title     string             `json:"title" bson:"title"`
	Questions []Question         `json:"questions" bson:"questions"`
	CreatedAt time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt time.Time          `json:"updated_at" bson:"updated_at"`
}

type Question struct {
	ID      string   `json:"id" bson:"id"`
	Text    string   `json:"text" bson:"text"`
	Type    string   `json:"type" bson:"type"` // multiple_choice, true_false, text
	Options []string `json:"options,omitempty" bson:"options,omitempty"`
	Correct string   `json:"correct" bson:"correct"`
	Points  int      `json:"points" bson:"points"`
}

type UserProgress struct {
	ID               primitive.ObjectID   `json:"id" bson:"_id,omitempty"`
	UserID           primitive.ObjectID   `json:"user_id" bson:"user_id"`
	PathID           primitive.ObjectID   `json:"path_id" bson:"path_id"`
	CompletedLessons []primitive.ObjectID `json:"completed_lessons" bson:"completed_lessons"`
	CurrentLesson    *primitive.ObjectID  `json:"current_lesson,omitempty" bson:"current_lesson,omitempty"`
	Progress         float64              `json:"progress" bson:"progress"` // percentage 0-100
	EnrolledAt       time.Time            `json:"enrolled_at" bson:"enrolled_at"`
	LastAccessedAt   time.Time            `json:"last_accessed_at" bson:"last_accessed_at"`
}

type QuizSubmission struct {
	ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID    primitive.ObjectID `json:"user_id" bson:"user_id"`
	QuizID    primitive.ObjectID `json:"quiz_id" bson:"quiz_id"`
	LessonID  primitive.ObjectID `json:"lesson_id" bson:"lesson_id"`
	Answers   map[string]string  `json:"answers" bson:"answers"` // question_id -> answer
	Score     float64            `json:"score" bson:"score"`
	MaxScore  int                `json:"max_score" bson:"max_score"`
	Passed    bool               `json:"passed" bson:"passed"`
	CreatedAt time.Time          `json:"created_at" bson:"created_at"`
}

// Learning Request/Response Models
type EnrollPathRequest struct {
	PathID string `json:"path_id" binding:"required"`
}

type CompleteLessonRequest struct {
	LessonID string `json:"lesson_id" binding:"required"`
}

type QuizSubmissionRequest struct {
	QuizID  string            `json:"quiz_id" binding:"required"`
	Answers map[string]string `json:"answers" binding:"required"` // question_id -> answer
}

type LearningPathResponse struct {
	*LearningPath
	TotalLessons     int     `json:"total_lessons"`
	UserProgress     float64 `json:"user_progress,omitempty"`
	IsEnrolled       bool    `json:"is_enrolled,omitempty"`
	CompletedLessons int     `json:"completed_lessons,omitempty"`
}

type LessonResponse struct {
	*Lesson
	IsCompleted bool  `json:"is_completed,omitempty"`
	Quiz        *Quiz `json:"quiz,omitempty"`
}

type ProgressResponse struct {
	PathID           string               `json:"path_id"`
	PathTitle        string               `json:"path_title"`
	Progress         float64              `json:"progress"`
	CompletedLessons []primitive.ObjectID `json:"completed_lessons"`
	CurrentLesson    *primitive.ObjectID  `json:"current_lesson,omitempty"`
	TotalLessons     int                  `json:"total_lessons"`
	EnrolledAt       time.Time            `json:"enrolled_at"`
	LastAccessedAt   time.Time            `json:"last_accessed_at"`
}

type QuizResultResponse struct {
	QuizID         string            `json:"quiz_id"`
	LessonID       string            `json:"lesson_id"`
	Score          float64           `json:"score"`
	MaxScore       int               `json:"max_score"`
	Percentage     float64           `json:"percentage"`
	Passed         bool              `json:"passed"`
	Answers        map[string]string `json:"answers"`
	CorrectAnswers map[string]string `json:"correct_answers"`
	CreatedAt      time.Time         `json:"created_at"`
}

// Streak Models
type StreakInfo struct {
	CurrentStreak    int       `json:"current_streak"`
	LongestStreak    int       `json:"longest_streak"`
	LastActivityDate time.Time `json:"last_activity_date"`
	StreakFrozen     bool      `json:"streak_frozen"`
	FreezeCount      int       `json:"freeze_count"`
	MaxFreezes       int       `json:"max_freezes"`
	CanFreeze        bool      `json:"can_freeze"`
	DaysUntilLoss    int       `json:"days_until_loss"`
}

type StreakActivity struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID       primitive.ObjectID `json:"user_id" bson:"user_id"`
	ActivityType string             `json:"activity_type" bson:"activity_type"` // lesson_completed, quiz_passed, daily_goal_met
	Date         time.Time          `json:"date" bson:"date"`
	CreatedAt    time.Time          `json:"created_at" bson:"created_at"`
}

type FreezeStreakRequest struct {
	Reason string `json:"reason,omitempty" example:"Vacation"`
}

// Activity Calendar Models (GitHub-like contribution graph)
type ActivityCalendarDay struct {
	Date         string `json:"date"`         // YYYY-MM-DD format
	ActivityCount int    `json:"activity_count"` // Number of activities on this day
	HasActivity  bool   `json:"has_activity"`   // Whether user was active on this day
	ActivityTypes []string `json:"activity_types,omitempty"` // Types of activities done
}

type ActivityCalendarWeek struct {
	Days []ActivityCalendarDay `json:"days"`
}

type ActivityCalendarResponse struct {
	Year         int                    `json:"year"`
	TotalDays    int                    `json:"total_days"`
	ActiveDays   int                    `json:"active_days"`
	CurrentStreak int                   `json:"current_streak"`
	LongestStreak int                   `json:"longest_streak"`
	Weeks        []ActivityCalendarWeek `json:"weeks"`
	Summary      ActivityCalendarSummary `json:"summary"`
}

type ActivityCalendarSummary struct {
	TotalActivities     int            `json:"total_activities"`
	ActivityBreakdown   map[string]int `json:"activity_breakdown"`   // Count by activity type
	MostActiveDay       string         `json:"most_active_day"`      // Date with most activities
	MostActiveCount     int            `json:"most_active_count"`    // Max activities in a single day
	ConsecutiveWeeks    int            `json:"consecutive_weeks"`    // Weeks with at least one activity
}

// Daily Activity Summary (for efficient querying)
type DailyActivitySummary struct {
	ID            primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID        primitive.ObjectID `json:"user_id" bson:"user_id"`
	Date          string             `json:"date" bson:"date"` // YYYY-MM-DD format
	ActivityCount int                `json:"activity_count" bson:"activity_count"`
	ActivityTypes []string           `json:"activity_types" bson:"activity_types"`
	FirstActivity time.Time          `json:"first_activity" bson:"first_activity"`
	LastActivity  time.Time          `json:"last_activity" bson:"last_activity"`
	CreatedAt     time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt     time.Time          `json:"updated_at" bson:"updated_at"`
}

// Common Response Models
type SuccessResponse struct {
	Message string `json:"message"`
}
