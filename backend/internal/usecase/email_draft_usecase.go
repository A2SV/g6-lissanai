package usecase

import (
	"context"
	"fmt"

	"lissanai.com/backend/internal/domain/entities"
	"lissanai.com/backend/internal/domain/interfaces"
)

// EmailUsecaseImpl implements interfaces.EmailUsecase
type EmailUsecaseImpl struct {
	emailService interfaces.EmailService
}

// NewEmailUsecase creates a new EmailUsecase implementation
func NewEmailUsecase(emailService interfaces.EmailService) interfaces.EmailUsecase {
	return &EmailUsecaseImpl{
		emailService: emailService,
	}
}

// GenerateProfessionalEmail implements the interface method
func (uc *EmailUsecaseImpl) GenerateProfessionalEmail(ctx context.Context, req *entities.EmailRequest) (*entities.EmailResponse, error) {
	// Input validation
	if req.Prompt == "" {
		return nil, fmt.Errorf("prompt cannot be empty")
	}

	// Call the AI service to generate email
	emailResp, err := uc.emailService.ProcessEmail(ctx, req)
	if err != nil {
		return nil, fmt.Errorf("failed to generate email: %w", err)
	}

	return emailResp, nil
}
