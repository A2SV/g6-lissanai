package interfaces

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
)

// PronunciationUsecase defines the contract for the pronunciation business logic.
type PronunciationUsecase interface {
	GetPracticeSentence(ctx context.Context) (*entities.PracticeSentence, error)
	AssessPronunciation(ctx context.Context, targetText string, audioData []byte, audioMimeType string) (*entities.PronunciationFeedback, error)
}
