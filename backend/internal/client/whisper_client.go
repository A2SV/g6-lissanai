// internal/client/whisper_client.go

package client

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log" // Import the log package
	"net/http"
	"strings"
	"time"
)

type WhisperClient struct {
	apiKey string
	client *http.Client
}

type WhisperResponse struct {
	Text string `json:"text"`
}

type WhisperErrorResponse struct {
	Error         string  `json:"error"`
	EstimatedTime float64 `json:"estimated_time,omitempty"`
}

// Pre-defined errors for better control and testing
var (
	ErrTranscriptionServiceAuth    = errors.New("authentication or payment error with the transcription service")
	ErrModelNotLoaded              = errors.New("model did not load in time after multiple retries")
	ErrUnexpectedTranscription     = errors.New("an unexpected error occurred with the transcription service")
)

func NewWhisperClient(apiKey string) *WhisperClient {
	return &WhisperClient{
		apiKey: apiKey,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (c *WhisperClient) Transcribe(ctx context.Context, audioData []byte) (string, error) {

	url := "https://api-inference.huggingface.co/models/openai/whisper-large-v3"

	for i := 0; i < 3; i++ {
		req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(audioData))
		if err != nil {
			return "", fmt.Errorf("failed to create whisper request: %w", err)
		}
		req.Header.Set("Authorization", "Bearer "+c.apiKey)
		req.Header.Set("Content-Type", "audio/ogg")

		resp, err := c.client.Do(req)
		if err != nil {
			return "", fmt.Errorf("failed to call whisper api: %w", err)
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			resp.Body.Close()
			return "", fmt.Errorf("failed to read whisper response body: %w", err)
		}
		
		// Always ensure the body is closed
		defer resp.Body.Close()

		// The successful case
		if resp.StatusCode == http.StatusOK {
			var wr WhisperResponse
			if err := json.Unmarshal(body, &wr); err != nil {
				// Log the raw body for debugging, but don't return it
				log.Printf("failed to parse successful whisper response, body: %s", string(body))
				return "", fmt.Errorf("failed to parse successful whisper response: %w", err)
			}
			return wr.Text, nil
		}

	
		// Handle specific client and server errors
		switch resp.StatusCode {
			// Handle auth, payment, or permission errors
			case http.StatusUnauthorized, http.StatusForbidden, http.StatusPaymentRequired, http.StatusTooManyRequests:
				// Log the detailed error for your own debugging
				log.Printf("Received auth/payment error from Whisper API. Status: %s, Body: %s", resp.Status, string(body))
				// Return a generic, safe error to the caller
				return "", ErrTranscriptionServiceAuth

			// Handle the specific "model loading" case with retries
			case http.StatusServiceUnavailable:
				var we WhisperErrorResponse
				if err := json.Unmarshal(body, &we); err == nil && strings.Contains(strings.ToLower(we.Error), "loading") {
					waitTime := time.Duration(we.EstimatedTime+2) * time.Second
					log.Printf("Model is loading, retrying in %v...", waitTime)
					time.Sleep(waitTime)
					continue // Retry the loop
				}

			// For any other unexpected error, log the details but return a generic error.
			default:
				log.Printf("Unexpected Whisper API response. Status: %s, Body: %s", resp.Status, string(body))
				return "", ErrUnexpectedTranscription
		}


	}

	return "", ErrModelNotLoaded
}