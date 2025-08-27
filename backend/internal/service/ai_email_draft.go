// service/ai_email_service.go
package service

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/google/generative-ai-go/genai"

	"google.golang.org/api/option"
	"lissanai.com/backend/internal/domain/entities"
)

// rawEmailResponse matches the AI's JSON output.
type rawEmailResponse struct {
	Subject        string `json:"subject"`
	GeneratedEmail string `json:"body"`
}

// aiEmailService holds the specific AI model that will handle requests.
type aiEmailService struct {
	model *genai.GenerativeModel
}

func NewAIEmailService() (*aiEmailService, error) {
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
	return &aiEmailService{model: model}, nil
}

// ProcessEmail handles the logic for both generating and editing emails.
func (s *aiEmailService) ProcessEmail(ctx context.Context, req *entities.EmailRequest) (*entities.EmailResponse, error) {
	var prompt string

	switch strings.ToUpper(req.Type) {
	case "GENERATE":
		prompt = fmt.Sprintf(`
You are an expert email writing assistant for Ethiopian professionals who may use English as a second language.
Your task is to generate a new, complete, professional email based on the user's request.
The user's request might be in English or Amharic; handle both appropriately.
The final email must be in English.

Consider the following if there exist:
- Tone: %s
- Template Type: %s

Respond ONLY with a single, minified JSON object. The JSON object must have exactly two keys: "subject" and "body".

User's Request: %s
`, req.Tone, req.TemplateType, req.Prompt)
	case "EDIT":
		prompt = fmt.Sprintf(`
You are an expert English communication coach for Ethiopian professionals.
Your task is to correct and improve an existing email draft to make it more professional.
Fix all grammatical errors, improve the tone, and enhance clarity.
The final, improved email must be in English.

Consider the following if there exist:
- Tone: %s
- Template Type: %s

Respond ONLY with a single, minified JSON object. The JSON object must have exactly two keys: "subject" and "body".

User's Email Draft: %s
`, req.Tone, req.TemplateType, req.Prompt)

	default:
		return nil, fmt.Errorf("invalid request type: '%s'. Must be 'GENERATE' or 'EDIT'", req.Type)
	}

	resp, err := s.model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		return nil, fmt.Errorf("failed to generate content: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("AI returned an empty response")
	}
	text := string(resp.Candidates[0].Content.Parts[0].(genai.Text))

	text = strings.TrimSpace(text)
	text = strings.TrimPrefix(text, "```json")
	text = strings.TrimPrefix(text, "```")
	text = strings.TrimSuffix(text, "```")
	text = strings.TrimSpace(text)

	var rawResp rawEmailResponse
	if err := json.Unmarshal([]byte(text), &rawResp); err != nil {
		return nil, fmt.Errorf("failed to parse AI response: %w\nRaw output from AI: %s", err, text)
	}

	cleanBody := strings.ReplaceAll(rawResp.GeneratedEmail, "\\n", "\n")

	emailResp := &entities.EmailResponse{
		Subject:        rawResp.Subject,
		GeneratedEmail: cleanBody,
	}

	return emailResp, nil
}
