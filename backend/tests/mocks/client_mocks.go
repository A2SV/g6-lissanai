// mocks/client_mocks.go
package mocks

import (
	"errors"
)

// MockGroqClient is a mock implementation of GroqClient
type MockGroqClient struct {
	responses map[string]string
	errors    map[string]error
}

// NewMockGroqClient creates a new mock Groq client
func NewMockGroqClient() *MockGroqClient {
	return &MockGroqClient{
		responses: make(map[string]string),
		errors:    make(map[string]error),
	}
}

// SetResponse sets a mock response for a given prompt
func (m *MockGroqClient) SetResponse(prompt, response string) {
	m.responses[prompt] = response
}

// SetError sets a mock error for a given prompt
func (m *MockGroqClient) SetError(prompt string, err error) {
	m.errors[prompt] = err
}

// GenerateText generates mock text using Groq
func (m *MockGroqClient) GenerateText(prompt string) (string, error) {
	if err, exists := m.errors[prompt]; exists {
		return "", err
	}

	if response, exists := m.responses[prompt]; exists {
		return response, nil
	}

	// Default mock response
	return "Mock Groq response for: " + prompt, nil
}

// GenerateChatResponse generates a mock chat response
func (m *MockGroqClient) GenerateChatResponse(messages []map[string]string) (string, error) {
	if len(messages) == 0 {
		return "", errors.New("no messages provided")
	}

	lastMessage := messages[len(messages)-1]
	prompt := lastMessage["content"]

	return m.GenerateText(prompt)
}

// Reset clears all data from the mock client
func (m *MockGroqClient) Reset() {
	m.responses = make(map[string]string)
	m.errors = make(map[string]error)
}

// MockWhisperClient is a mock implementation of WhisperClient
type MockWhisperClient struct {
	transcriptions map[string]string
	errors         map[string]error
}

// NewMockWhisperClient creates a new mock Whisper client
func NewMockWhisperClient() *MockWhisperClient {
	return &MockWhisperClient{
		transcriptions: make(map[string]string),
		errors:         make(map[string]error),
	}
}

// SetTranscription sets a mock transcription for audio data
func (m *MockWhisperClient) SetTranscription(audioData string, transcription string) {
	m.transcriptions[audioData] = transcription
}

// SetError sets a mock error for audio data
func (m *MockWhisperClient) SetError(audioData string, err error) {
	m.errors[audioData] = err
}

// TranscribeAudio transcribes mock audio data
func (m *MockWhisperClient) TranscribeAudio(audioData []byte) (string, error) {
	audioKey := string(audioData)

	if err, exists := m.errors[audioKey]; exists {
		return "", err
	}

	if transcription, exists := m.transcriptions[audioKey]; exists {
		return transcription, nil
	}

	// Default mock transcription
	return "Mock transcription for audio data", nil
}

// Reset clears all data from the mock client
func (m *MockWhisperClient) Reset() {
	m.transcriptions = make(map[string]string)
	m.errors = make(map[string]error)
}

// MockElevenLabsClient is a mock implementation of ElevenLabsClient
type MockElevenLabsClient struct {
	audioData map[string][]byte
	errors    map[string]error
}

// NewMockElevenLabsClient creates a new mock ElevenLabs client
func NewMockElevenLabsClient() *MockElevenLabsClient {
	return &MockElevenLabsClient{
		audioData: make(map[string][]byte),
		errors:    make(map[string]error),
	}
}

// SetAudioData sets mock audio data for text
func (m *MockElevenLabsClient) SetAudioData(text string, audioData []byte) {
	m.audioData[text] = audioData
}

// SetError sets a mock error for text
func (m *MockElevenLabsClient) SetError(text string, err error) {
	m.errors[text] = err
}

// TextToSpeech converts mock text to speech
func (m *MockElevenLabsClient) TextToSpeech(text, voiceID string) ([]byte, error) {
	if err, exists := m.errors[text]; exists {
		return nil, err
	}

	if audioData, exists := m.audioData[text]; exists {
		return audioData, nil
	}

	// Default mock audio data
	return []byte("mock audio data for: " + text), nil
}

// Reset clears all data from the mock client
func (m *MockElevenLabsClient) Reset() {
	m.audioData = make(map[string][]byte)
	m.errors = make(map[string]error)
}

// MockAIService is a mock implementation of AIService
type MockAIService struct {
	responses map[string]string
	errors    map[string]error
}

// NewMockAIService creates a new mock AI service
func NewMockAIService() *MockAIService {
	return &MockAIService{
		responses: make(map[string]string),
		errors:    make(map[string]error),
	}
}

// SetResponse sets a mock response for a given prompt
func (m *MockAIService) SetResponse(prompt, response string) {
	m.responses[prompt] = response
}

// SetError sets a mock error for a given prompt
func (m *MockAIService) SetError(prompt string, err error) {
	m.errors[prompt] = err
}

// GenerateText generates mock text using AI
func (m *MockAIService) GenerateText(prompt string) (string, error) {
	if err, exists := m.errors[prompt]; exists {
		return "", err
	}

	if response, exists := m.responses[prompt]; exists {
		return response, nil
	}

	// Default mock response
	return "Mock AI response for: " + prompt, nil
}

// CheckGrammar checks grammar using mock AI
func (m *MockAIService) CheckGrammar(text string) (string, error) {
	prompt := "grammar_check:" + text
	return m.GenerateText(prompt)
}

// GenerateEmailDraft generates a mock email draft
func (m *MockAIService) GenerateEmailDraft(prompt string) (string, error) {
	prompt = "email_draft:" + prompt
	return m.GenerateText(prompt)
}

// AssessPronunciation assesses pronunciation using mock AI
func (m *MockAIService) AssessPronunciation(text, audioData string) (string, error) {
	prompt := "pronunciation:" + text + ":" + audioData
	return m.GenerateText(prompt)
}

// Reset clears all data from the mock service
func (m *MockAIService) Reset() {
	m.responses = make(map[string]string)
	m.errors = make(map[string]error)
}

// MockChatAIService is a mock implementation of ChatAIService
type MockChatAIService struct {
	responses map[string]string
	errors    map[string]error
}

// NewMockChatAIService creates a new mock chat AI service
func NewMockChatAIService() *MockChatAIService {
	return &MockChatAIService{
		responses: make(map[string]string),
		errors:    make(map[string]error),
	}
}

// SetResponse sets a mock response for a given prompt
func (m *MockChatAIService) SetResponse(prompt, response string) {
	m.responses[prompt] = response
}

// SetError sets a mock error for a given prompt
func (m *MockChatAIService) SetError(prompt string, err error) {
	m.errors[prompt] = err
}

// GenerateResponse generates a mock chat response
func (m *MockChatAIService) GenerateResponse(prompt string) (string, error) {
	if err, exists := m.errors[prompt]; exists {
		return "", err
	}

	if response, exists := m.responses[prompt]; exists {
		return response, nil
	}

	// Default mock response
	return "Mock chat response for: " + prompt, nil
}

// GenerateInterviewQuestion generates a mock interview question
func (m *MockChatAIService) GenerateInterviewQuestion(sessionID string, difficulty string) (string, error) {
	prompt := "interview_question:" + sessionID + ":" + difficulty
	return m.GenerateResponse(prompt)
}

// EvaluateAnswer evaluates a mock answer
func (m *MockChatAIService) EvaluateAnswer(question, answer string) (string, error) {
	prompt := "evaluate_answer:" + question + ":" + answer
	return m.GenerateResponse(prompt)
}

// Reset clears all data from the mock service
func (m *MockChatAIService) Reset() {
	m.responses = make(map[string]string)
	m.errors = make(map[string]error)
}
