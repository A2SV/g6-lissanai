package interfaces

import "lissanai.com/backend/internal/domain/models"

// SessionRepository defines operations for sessions
type SessionRepository interface {
	CreateSession(session *models.Session) error
	GetSessionByID(sessionID string) (*models.Session, error)
	UpdateSessionProgress(sessionID string, completedQuestions int, score int) error
	DeleteSession(sessionID string) error
}

// MessageRepository defines operations for messages
type MessageRepository interface {
	AddMessage(msg *models.Message) error
	GetMessagesBySession(sessionID string) ([]*models.Message, error)
	GetMessageByID(messageID string) (*models.Message, error)
	UpdateMessageFeedback(messageID string, feedback *models.Feedback) error
	DeleteMessagesBySession(sessionID string) error
}

// AiService defines the contract for AI-related operations
type AiService interface {

	// GenerateFeedback analyzes the user's answer and returns
	// structured feedback (grammar, pronunciation, clarity, etc).
	GenerateFeedback(sessionID string, question string, answer string) (*models.Feedback, error)

	// SummarizeSession creates a final session summary
	// including strengths, weaknesses, and overall score.
	SummarizeSession(session *models.Session, Messages []models.Message) (*models.SessionSummary, error)
}
