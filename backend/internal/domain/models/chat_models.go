package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Session struct {
	ID                 string    `bson:"_id,omitempty" json:"session_id"`
	SessionType        string    `bson:"session_type" json:"session_type"`
	TotalQuestions     int       `bson:"total_questions" json:"total_questions"`
	CompletedQuestions int       `bson:"completed_questions" json:"completed_questions"`
	ScorePercentage    int       `bson:"score_percentage" json:"score_percentage"`
	CreatedAt          time.Time `bson:"created_at" json:"created_at"`
	UpdatedAt          time.Time `bson:"updated_at" json:"updated_at"`
	UserID             string    `bson:"user_id" json:"user_id"`
}

type FeedbackPoint struct {
	Type        string `bson:"type" json:"type"` // grammar, pronunciation, structure
	FocusPhrase string `bson:"focus_phrase" json:"focus_phrase"`
	Suggestion  string `bson:"suggestion" json:"suggestion"`
}

type Feedback struct {
	OverallSummary string          `bson:"overall_summary" json:"overall_summary"`
	FeedbackPoints []FeedbackPoint `bson:"feedback_points" json:"feedback_points"`
	ScorePercent   int             `bson:"score_percentage" json:"score_percentage"`
}

type Message struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	SessionID string             `bson:"session_id" json:"session_id"`
	Answer    string             `bson:"answer" json:"answer"`
	Feedback  *Feedback          `bson:"feedback,omitempty" json:"feedback,omitempty"`
	Question  string             `bson:"question" json:"question"`
	CreatedAt time.Time          `bson:"created_at" json:"created_at"`
}

type SessionSummary struct {
	SessionID      string   `bson:"session_id" json:"session_id"`
	TotalQuestions int      `bson:"total_questions" json:"total_questions"`
	Completed      int      `bson:"completed" json:"completed"`
	Strengths      []string `bson:"strengths" json:"strengths"`
	Weaknesses     []string `bson:"weaknesses" json:"weaknesses"`
	FinalScore     int      `bson:"final_score" json:"final_score"` // out of 100
	CreatedAt      int64    `bson:"created_at" json:"created_at"`
}

type SessionReturn struct {
	SessionID      string `json:"session_id"`
	QuestionNumber int    `json:"question_number"`
}

type SubmitAnswerRequest struct {
	SessionID string `json:"session_id" example:"13c70d60-8dab-4b08-b454-5225dcca1809"`
	Answer    string `json:"answer" example:"My answer to the question"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type NextQuestionReturn struct {
	Question string `json:"question"`
}
