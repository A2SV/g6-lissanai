// In file: internal/usecase/pronunciation_usecase.go
package usecase

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"

	// google.golang.org/genai is NO LONGER NEEDED here for the API call
	"github.com/google/uuid"
	"lissanai.com/backend/internal/domain/entities"
	"lissanai.com/backend/internal/domain/interfaces"
)

// pronunciationUsecase will now hold the API key directly.
type pronunciationUsecase struct {
	apiKey     string
	httpClient *http.Client
}

// NewPronunciationUsecase now takes the API key directly.
func NewPronunciationUsecase(apiKey string) interfaces.PronunciationUsecase {
	return &pronunciationUsecase{
		apiKey:     apiKey,
		httpClient: &http.Client{},
	}
}

func (uc *pronunciationUsecase) GetPracticeSentence(ctx context.Context) (*entities.PracticeSentence, error) {
	// 1. The prompt to generate a practice sentence.
	prompt := `
You are an English language coach for Ethiopian Amharic speakers.
Your task is to generate one single, interesting, and practical English sentence for pronunciation practice.

Here are the rules:
1.  The sentence must be less than or equal to 100 characters.
2.  The sentence must contain a mix of words with sounds that are typically challenging for Amharic speakers (e.g., words with 'v', 'p', the 'th' sound, or complex vowel sounds like in 'ship' vs 'sheep').
3.  To ensure variety, please base the sentence on one of the following themes: Technology, Business, Travel, or Everyday Life. Choose a theme at random.
4.  Your entire response must be ONLY the sentence itself. Do not include quotes, theme names, or any other text.
`

	// 2. Define structs for this simple text-only request and response.
	type part struct {
		Text string `json:"text"`
	}
	type content struct {
		Parts []part `json:"parts"`
	}
	type requestPayload struct {
		Contents []content `json:"contents"`
	}
	type geminiResponse struct { // Can reuse this from the other method
		Candidates []struct {
			Content struct {
				Parts []part `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}

	// 3. Construct and send the request.
	payload := requestPayload{Contents: []content{{Parts: []part{{Text: prompt}}}}}
	jsonData, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal sentence request: %w", err)
	}

	model := "gemini-1.5-flash-latest"
	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", model, uc.apiKey)

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create http request for sentence generation: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := uc.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to call gemini for sentence generation: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := ioutil.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("gemini api returned an error for sentence generation. Status: %s, Body: %s", resp.Status, string(respBody))
	}

	// 4. Parse the response.
	var geminiResp geminiResponse
	if err := json.Unmarshal(respBody, &geminiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal sentence response: %w", err)
	}

	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("gemini returned no sentence content")
	}

	generatedText := geminiResp.Candidates[0].Content.Parts[0].Text
	finalSentence := strings.Trim(generatedText, "\" \n")

	// 5. Return the single, dynamically generated sentence.
	return &entities.PracticeSentence{
		ID:   fmt.Sprintf("dyn_%s", uuid.New().String()),
		Text: finalSentence,
	}, nil
}

// --- THIS IS THE NEW, MANUALLY IMPLEMENTED VERSION ---
// AssessPronunciation builds and sends a raw HTTP request to the Gemini API.
func (uc *pronunciationUsecase) AssessPronunciation(ctx context.Context, targetText string, audioData []byte, audioMimeType string) (*entities.PronunciationFeedback, error) {
	// 1. The prompt remains the same.
	prompt := fmt.Sprintf(`
You are an expert English pronunciation coach for an Ethiopian user.
Analyze the audio file of a user speaking and compare it to a target sentence. The user was asked to say: "%s"
Your response MUST be a single, valid, minified JSON object and nothing else.
The JSON object must have three keys: "overall_accuracy_score", "mispronouncedwords", and "full_feedback_summary".
- "overall_accuracy_score": A number between 0 and 100.
- "mispronouncedwords": A list of strings representing only the words the user mispronounced. If none were mispronounced, this must be an empty list [].
- "full_feedback_summary": A short, encouraging, one or two-sentence summary.
`, targetText)

	// 2. Define the JSON structs for the request body.
	// We need to encode the audio data as a base64 string.
	type blob struct {
		MIMEType string `json:"mimeType"`
		Data     []byte `json:"data"`
	}

	type part struct {
		Text string `json:"text,omitempty"`
		Data *blob  `json:"inlineData,omitempty"`
	}

	type content struct {
		Parts []part `json:"parts"`
	}
	type requestPayload struct {
		Contents []content `json:"contents"`
	}

	// 3. Construct the request payload.
	payload := requestPayload{
		Contents: []content{
			{
				Parts: []part{
					{Text: prompt},
					{Data: &blob{MIMEType: audioMimeType, Data: audioData}},
				},
			},
		},
	}
	jsonData, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal gemini request: %w", err)
	}

	// 4. Create the HTTP request manually.
	model := "gemini-1.5-flash-latest"
	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", model, uc.apiKey)

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create http request for gemini: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	// 5. Send the request.
	resp, err := uc.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to call gemini api: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read gemini response body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("gemini api returned an error. Status: %s, Body: %s", resp.Status, string(respBody))
	}

	// 6. Define structs to parse the response and extract the text.
	type responsePart struct {
		Text string `json:"text"`
	}
	type contentResponse struct {
		Parts []responsePart `json:"parts"`
	}
	type candidate struct {
		Content contentResponse `json:"content"`
	}
	type geminiResponse struct {
		Candidates []candidate `json:"candidates"`
	}

	var geminiResp geminiResponse
	if err := json.Unmarshal(respBody, &geminiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal gemini response: %w. Raw body: %s", err, string(respBody))
	}

	// 7. Extract and clean the final JSON from the response.
	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("received an empty response from Gemini")
	}

	rawJson := geminiResp.Candidates[0].Content.Parts[0].Text
	cleanedJson := strings.Trim(string(rawJson), "```json \n")
	log.Printf("Raw JSON from Gemini: %s", cleanedJson)

	var feedback entities.PronunciationFeedback
	if err := json.Unmarshal([]byte(cleanedJson), &feedback); err != nil {
		return nil, fmt.Errorf("failed to parse final feedback JSON from Gemini: %w", err)
	}

	return &feedback, nil
}
