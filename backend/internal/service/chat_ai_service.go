package service

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
	"lissanai.com/backend/internal/domain/models"
)

// ChatAiService implements AiService interface
type ChatAiService struct {
	model *genai.GenerativeModel
}

// NewChatAiService creates a new Gemini AI service client
func NewChatAiService(apiKey string) (*ChatAiService, error) {
	ctx := context.Background()

	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return nil, fmt.Errorf("failed to create Gemini AI client: %w", err)
	}

	// Use gemini-1.5-flash for quick feedback tasks
	model := client.GenerativeModel("gemini-1.5-flash")

	return &ChatAiService{model: model}, nil
}

// GenerateFeedback analyzes a user's answer and returns structured feedback.
func (cs *ChatAiService) GenerateFeedback(sessionID string, question string, answer string) (*models.Feedback, error) {
	ctx := context.Background()

	prompt := fmt.Sprintf(`
You are an English tutor evaluating a student's interview response. 
Analyze the answer and return structured JSON feedback. 
Focus on grammar, clarity, fluency, and pronunciation.

Question: %s
Answer: %s

Return strictly in this JSON format:
{
  "overall_summary": "string",
  "feedback_points": [
    {
      "type": "grammar|pronunciation|structure",
      "focus_phrase": "string",
      "suggestion": "string"
    }
  ],
  "score_percentage": number
}
`, question, answer)

	resp, err := cs.model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return nil, fmt.Errorf("failed to generate feedback: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("no valid feedback returned")
	}

	part := resp.Candidates[0].Content.Parts[0]
	raw, ok := part.(genai.Text)
	if !ok {
		return nil, fmt.Errorf("unexpected response type: %#v", part)
	}

	jsonStr := cleanJSON(string(raw))

	var feedback models.Feedback
	if err := json.Unmarshal([]byte(jsonStr), &feedback); err != nil {
		return nil, fmt.Errorf("failed to parse feedback JSON: %w\nRaw response: %s", err, jsonStr)
	}

	return &feedback, nil
}

// SummarizeSession produces an overall session summary
func (cs *ChatAiService) SummarizeSession(session *models.Session, messages []models.Message) (*models.SessionSummary, error) {
	ctx := context.Background()

	// Convert messages into a JSON-like string for AI context
	msgStr := ""
	for i, m := range messages {
		if m.Feedback != nil {
			msgStr += fmt.Sprintf(
				"Q%d: %s\nA: %s\nFeedback: %+v\n\n",
				i+1, m.Question, m.Answer, m.Feedback,
			)
		} else {
			msgStr += fmt.Sprintf(
				"Q%d: %s\nA: %s\n\n",
				i+1, m.Question, m.Answer,
			)
		}
	}

	prompt := fmt.Sprintf(`
You are an English tutor. Summarize the entire interview session.

Here are the questions, answers, and feedback:
%s

Return strictly in this JSON format:
{
  "strengths": ["string", "string"],
  "weaknesses": ["string", "string"],
  "overall_score": number,
  "recommendations": ["string", "string"]
}
`, msgStr)

	resp, err := cs.model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return nil, fmt.Errorf("failed to generate session summary: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("no valid summary returned")
	}

	part := resp.Candidates[0].Content.Parts[0]
	raw, ok := part.(genai.Text)
	if !ok {
		return nil, fmt.Errorf("unexpected response type: %#v", part)
	}

	jsonStr := cleanJSON(string(raw))

	var summary models.SessionSummary
	if err := json.Unmarshal([]byte(jsonStr), &summary); err != nil {
		return nil, fmt.Errorf("failed to parse summary JSON: %w\nRaw response: %s", err, jsonStr)
	}

	return &summary, nil
}
