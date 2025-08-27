package interfaces

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
)

// EmailUsecase defines the methods the controller can call
type EmailUsecase interface {
	// GenerateProfessionalEmail takes a user request and returns a professional email
	GenerateProfessionalEmail(ctx context.Context, req *entities.EmailRequest) (*entities.EmailResponse, error)
}
