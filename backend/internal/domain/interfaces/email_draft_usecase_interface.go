package interfaces

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
)

// EmailUsecase defines the methods the controller can call
type EmailUsecase interface {
	// GenerateEmailFromPrompt handles the business logic for creating a new email.
	GenerateEmailFromPrompt(ctx context.Context, req *entities.GenerateEmailRequest) (*entities.EmailResponse, error)

	// EditEmailDraft handles the business logic for improving an existing email draft.
	EditEmailDraft(ctx context.Context, req *entities.EditEmailRequest) (*entities.EditEmailResponse, error)
}
