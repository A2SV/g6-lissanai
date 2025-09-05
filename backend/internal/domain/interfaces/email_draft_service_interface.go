package interfaces

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
)

// EmailService defines the contract for generating emails with AI
type EmailService interface {
	// GenerateEmailFromPrompt creates a new email based on a user's prompt.
	GenerateEmailFromPrompt(ctx context.Context, req *entities.GenerateEmailRequest) (*entities.EmailResponse, error)

	// EditEmailDraft corrects and improves an existing email draft.
	EditEmailDraft(ctx context.Context, req *entities.EditEmailRequest) (*entities.EditEmailResponse, error)
}
