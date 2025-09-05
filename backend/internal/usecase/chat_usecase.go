package usecase

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"lissanai.com/backend/internal/domain/interfaces"
	"lissanai.com/backend/internal/domain/models"
)

func generateSessionID() string {
	return uuid.NewString() // generates a globally unique UUID v4
}

// ChatUsecase handles the interview flow
type ChatUsecase struct {
	sessionRepo interfaces.SessionRepository
	messageRepo interfaces.MessageRepository
	aiService   interfaces.AiService
	questions   []string // hardcoded or loaded from DB
}

// NewChatUsecase constructor
func NewChatUsecase(
	sessionRepo interfaces.SessionRepository,
	messageRepo interfaces.MessageRepository,
	aiService interfaces.AiService,
) *ChatUsecase {
	questions := []string{
		"Tell me about a project you worked on recently.",
		"Why do you want this job?",
		"What is your biggest strength?",
		"What is your biggest weakness?",
		"Where do you see yourself in 5 years?",
	}

	return &ChatUsecase{
		sessionRepo: sessionRepo,
		messageRepo: messageRepo,
		aiService:   aiService,
		questions:   questions,
	}
}
func calculateScore(completed, total int) int {
	if total == 0 {
		return 0
	}
	return int(float64(completed) / float64(total) * 100)
}

// StartSession creates a new interview session
func (u *ChatUsecase) StartSession(userID string) (*models.SessionReturn, error) {
	session := &models.Session{
		ID:                 generateSessionID(),
		CompletedQuestions: -1,
		ScorePercentage:    0,
		SessionType:        "interview",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
		UserID:             userID,
	}

	if err := u.sessionRepo.CreateSession(session); err != nil {
		return nil, err
	}

	return &models.SessionReturn{SessionID: session.ID, QuestionNumber: len(u.questions)}, nil
}

// GetNextQuestion returns the next question for the session
func (u *ChatUsecase) GetNextQuestion(sessionID string) (*models.NextQuestionReturn, error) {
	session, err := u.sessionRepo.GetSessionByID(sessionID)
	if err != nil {
		return nil, err
	}
	session.CompletedQuestions++
	session.ScorePercentage = calculateScore(session.CompletedQuestions, len(u.questions))
	session.UpdatedAt = time.Now()
	if err := u.sessionRepo.UpdateSessionProgress(session.ID, session.CompletedQuestions, session.ScorePercentage); err != nil {
		return nil, err
	}
	if session.CompletedQuestions >= len(u.questions) {
		return nil, errors.New("no more questions left")
	}
	question := u.questions[session.CompletedQuestions]

	u.sessionRepo.UpdateSessionProgress(session.ID, session.CompletedQuestions, session.ScorePercentage)
	return &models.NextQuestionReturn{Question: question}, nil
}

// SubmitAnswer stores the answer and returns structured feedback
func (u *ChatUsecase) SubmitAnswer(sessionID, answerText string) (*models.Feedback, error) {
	session, err := u.sessionRepo.GetSessionByID(sessionID)
	if err != nil {
		return nil, err
	}

	if session.CompletedQuestions >= len(u.questions) {
		return nil, errors.New("all questions completed")
	}

	question := u.questions[session.CompletedQuestions]

	feedback, err := u.aiService.GenerateFeedback(sessionID, question, answerText)
	if err != nil {
		return nil, err
	}

	msg := &models.Message{
		SessionID: sessionID,
		Answer:    answerText,
		Feedback:  feedback,
		CreatedAt: time.Now(),
		Question:  question,
	}

	if err := u.messageRepo.AddMessage(msg); err != nil {
		return nil, err
	}

	return feedback, nil
}

// EndSession returns final summary with score
func (u *ChatUsecase) EndSession(sessionID string) (*models.SessionSummary, error) {
	session, err := u.sessionRepo.GetSessionByID(sessionID)
	if err != nil {
		return nil, err
	}

	messages, err := u.messageRepo.GetMessagesBySession(sessionID)
	if err != nil {
		return nil, err
	}

	var strengths, weaknesses []string
	for _, msg := range messages {
		for _, fb := range msg.Feedback.FeedbackPoints {
			switch fb.Type {
			case "grammar", "pronunciation", "structure":
				weaknesses = append(weaknesses, fb.FocusPhrase)
			default:
				strengths = append(strengths, fb.FocusPhrase)
			}
		}
	}

	summary := &models.SessionSummary{
		SessionID:      session.ID,
		TotalQuestions: len(u.questions),
		Completed:      session.CompletedQuestions,
		Strengths:      strengths,
		Weaknesses:     weaknesses,
		FinalScore:     session.ScorePercentage, // percentage out of 100
		CreatedAt:      time.Now().Unix(),
	}

	return summary, nil
}
