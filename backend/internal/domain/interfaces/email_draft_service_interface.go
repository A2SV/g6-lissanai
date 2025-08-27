package interfaces

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
)

// EmailService defines the contract for generating emails with AI
type EmailService interface {
	ProcessEmail(ctx context.Context, req *entities.EmailRequest) (*entities.EmailResponse, error)
}
