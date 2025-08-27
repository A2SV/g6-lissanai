package service

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"os"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
	"lissanai.com/backend/internal/domain/models"
)

type AiService struct {
	model *genai.GenerativeModel
}

// NewAiService creates a new Gemini AI service client
func NewAiService() (*AiService, error) {
	ctx := context.Background()

	apiKey := os.Getenv("GEMINI_API_KEY") // <-- READ FROM ENVIRONMENT
	if apiKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY environment variable not set")
	}

	// Use the apiKey variable here
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return nil, fmt.Errorf("failed to create Gemini AI client: %w", err)
	}

	model := client.GenerativeModel("gemini-1.5-flash")
	return &AiService{model: model}, nil
}

// cleanJSON strips any ```json or ``` wrappers from the AI output
func cleanJSON(raw string) string {
	raw = strings.TrimSpace(raw)
	raw = strings.TrimPrefix(raw, "```json")
	raw = strings.TrimPrefix(raw, "```")
	raw = strings.TrimSuffix(raw, "```")
	return strings.TrimSpace(raw)
}

// CheckGrammar sends text to Gemini AI and returns structured grammar corrections
func (as *AiService) CheckGrammar(text string) (*models.GrammarResponse, error) {
	ctx := context.Background()

	prompt := fmt.Sprintf(`
You are a grammar correction assistant.
Correct the grammar and spelling of the following text.
Return the result strictly in JSON format with the following structure:
{
  "corrected_text": "string",
  "corrections": [
    {
      "original_phrase": "string",
      "corrected_phrase": "string",
      "explanation": "string"
    }
  ]
}

Text: %s
`, text)

	// Send request to Gemini
	resp, err := as.model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return nil, fmt.Errorf("failed to generate content: %w", err)
	}

	log.Printf("Raw AI response: %+v\n", resp)

	// Validate response
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("no valid content returned")
	}

	// Extract the first text part
	part := resp.Candidates[0].Content.Parts[0]
	raw, ok := part.(genai.Text)
	if !ok {
		return nil, fmt.Errorf("unexpected response type: %#v", part)
	}

	// Clean JSON string
	jsonStr := cleanJSON(string(raw))

	// Unmarshal into GrammarResponse struct
	var grammarResp models.GrammarResponse
	if err := json.Unmarshal([]byte(jsonStr), &grammarResp); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w\nRaw response: %s", err, jsonStr)
	}

	return &grammarResp, nil
}
