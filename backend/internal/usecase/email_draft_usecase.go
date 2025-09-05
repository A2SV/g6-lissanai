package usecase

import (
	"context"

	"lissanai.com/backend/internal/domain/entities"
	"lissanai.com/backend/internal/domain/interfaces"
)

type emailUsecase struct {
	emailService interfaces.EmailService
}

func NewEmailUsecase(emailService interfaces.EmailService) interfaces.EmailUsecase {
	return &emailUsecase{emailService: emailService}
}

// GenerateEmailFromPrompt passes the request to the service layer.
func (uc *emailUsecase) GenerateEmailFromPrompt(ctx context.Context, req *entities.GenerateEmailRequest) (*entities.EmailResponse, error) {
	return uc.emailService.GenerateEmailFromPrompt(ctx, req)
}

// EditEmailDraft passes the request to the service layer.
func (uc *emailUsecase) EditEmailDraft(ctx context.Context, req *entities.EditEmailRequest) (*entities.EditEmailResponse, error) {
	return uc.emailService.EditEmailDraft(ctx, req)
}
