// internal/client/groq_client.go

package client

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

type GroqClient struct {
	apiKey string
	client *http.Client
}

type GroqRequest struct {
	Model    string        `json:"model"`
	Messages []GroqMessage `json:"messages"`
}
type GroqMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}
type GroqResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

func NewGroqClient(apiKey string) *GroqClient {
	return &GroqClient{
		apiKey: apiKey,
		client: &http.Client{
			Timeout: 60 * time.Second,
		},
	}
}

func (c *GroqClient) GenerateContent(ctx context.Context, prompt string) (string, error) {
	reqBody := GroqRequest{
	
		Model: "llama-3.3-70b-versatile", 
		Messages: []GroqMessage{
			{Role: "system", Content: "You are a helpful AI assistant for a conversation. Be concise and conversational in your responses."},
			{Role: "user", Content: prompt},
		},
	}
	data, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal groq request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", "https://api.groq.com/openai/v1/chat/completions", bytes.NewBuffer(data))
	if err != nil {
		return "", fmt.Errorf("failed to create groq request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+c.apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to call groq api: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return "", fmt.Errorf("groq API returned non-200 status: %s, body: %s", resp.Status, string(body))
	}

	var gr GroqResponse
	if err := json.NewDecoder(resp.Body).Decode(&gr); err != nil {
		return "", fmt.Errorf("failed to decode groq response: %w", err)
	}

	if len(gr.Choices) > 0 && gr.Choices[0].Message.Content != "" {
		return gr.Choices[0].Message.Content, nil
	}

	return "", errors.New("groq response contained no content")
}