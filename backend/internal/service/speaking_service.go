package service

import (
	"context"
	"fmt"
	"strings"

	"lissanai.com/backend/internal/client"
	// If you moved shared interfaces/types to internal/common, import it here:
	// "lissanai.com/backend/internal/common"
)

type SpeakingService interface {
	ProcessAudioFeedback(ctx context.Context, audioData []byte) ([]byte, error)
}


type speakingServiceImpl struct {
	groqClient         *client.GroqClient
	whisperClient      *client.WhisperClient
	unrealSpeechClient *client.UnrealSpeechTTSClient // 1. Renamed the field
}

// 2. Updated the function signature to accept the new client type
func NewSpeakingService(groq *client.GroqClient, whisper *client.WhisperClient, unreal *client.UnrealSpeechTTSClient) SpeakingService {
	return &speakingServiceImpl{
		groqClient:         groq,
		whisperClient:      whisper,
		unrealSpeechClient: unreal, // 3. Updated the assignment
	}
}
func (s *speakingServiceImpl) ProcessAudioFeedback(ctx context.Context, audioData []byte) ([]byte, error) {
	// 1️⃣ STT: Convert audio to text
	text, err := s.whisperClient.Transcribe(ctx, audioData)
	if err != nil {
		return nil, fmt.Errorf("STT error: %w", err)
	}
	if text == "" {
		return nil, fmt.Errorf("no speech detected in audio")
	}
	fmt.Println("transcripted text:", text)

	// 2️⃣ LLM: Generate response with strong English-only instruction
	prompt := fmt.Sprintf(`
You are a friendly person having a casual chat. 
Always reply only in English, in a natural and conversational way.
Keep your answers short and relaxed, like talking to a friend.

User said: %s
`, text)

	response, err := s.groqClient.GenerateContent(ctx, prompt)
	if err != nil {
		return nil, fmt.Errorf("LLM error: %w", err)
	}

	// 🧹 Clean and trim response before TTS
	cleanedResponse := strings.TrimSpace(response)
	if len(cleanedResponse) == 0 {
		return nil, fmt.Errorf("LLM generated an empty response")
	}

	// 🔒 Extra safeguard: ensure response is English only
	if !isEnglish(cleanedResponse) {
		fmt.Println("⚠️ Non-English detected, rewriting...")
		rePrompt := "Rewrite this strictly in English, simple and clear: " + cleanedResponse
		englishResponse, err := s.groqClient.GenerateContent(ctx, rePrompt)
		if err == nil && len(strings.TrimSpace(englishResponse)) > 0 {
			cleanedResponse = strings.TrimSpace(englishResponse)
		}
	}

	// Keep responses short for TTS
	if len(cleanedResponse) > 150 {
		cleanedResponse = cleanedResponse[:150]
	}

	// 3️⃣ TTS: Convert response to audio
	ttsAudio, err := s.unrealSpeechClient.GenerateAudio(cleanedResponse)
	if err != nil {
		return nil, fmt.Errorf("TTS error: %w", err)
	}

	return ttsAudio, nil
}

// Helper function to check if a string is mostly English (ASCII letters only)
func isEnglish(s string) bool {
	for _, r := range s {
		if r > 127 { // non-ASCII char (Arabic, Amharic, Chinese, etc.)
			return false
		}
	}
	return true
}
