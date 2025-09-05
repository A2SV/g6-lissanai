package interfaces

import "lissanai.com/backend/internal/domain/models"

type AiServiceInterface interface {
	CheckGrammar(text string) (*models.GrammarResponse, error)
}
