package usecase

import (
	"lissanai.com/backend/internal/domain/interfaces"
	"lissanai.com/backend/internal/domain/models"
)

// GrammarUsecase handles grammar checking.
type GrammarUsecase struct {
	AiService interfaces.AiServiceInterface
}

// usecase/grammar_usecase.go
func NewGrammarUsecase(aiService interfaces.AiServiceInterface) *GrammarUsecase {
	return &GrammarUsecase{AiService: aiService}
}

func (g *GrammarUsecase) CheckGrammar(text string) (*models.GrammarResponse, error) {
	return g.AiService.CheckGrammar(text)
}
