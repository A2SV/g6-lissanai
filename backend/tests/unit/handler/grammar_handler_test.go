package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"lissanai.com/backend/internal/domain/models"
	"lissanai.com/backend/internal/handler"
	"lissanai.com/backend/internal/usecase"
	"lissanai.com/backend/tests/mocks"
)

// GrammarRequest defines the request body for grammar checking.
type GrammarRequest struct {
	Text string `json:"text" binding:"required"`
}

func TestGrammarHandler_CheckGrammar(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		request        GrammarRequest
		mockSetup      func(*mocks.MockGrammarUsecase)
		expectedStatus int
	}{
		{
			name: "Successful grammar check",
			request: GrammarRequest{
				Text: "This are wrong sentence.",
			},
			mockSetup: func(m *mocks.MockGrammarUsecase) {
				m.On("CheckGrammar", "This are wrong sentence.").Return(
					&models.GrammarResponse{
						CorrectedText: "This is a wrong sentence.",
						Corrections: []models.Correction{
							{
								OriginalPhrase:  "This are",
								CorrectedPhrase: "This is",
								Explanation: models.Explanation{
									English: "Subject-verb disagreement",
									Amharic: "Subject-verb disagreement in Amharic",
								},
							},
						},
					}, nil)
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "Empty text",
			request: GrammarRequest{
				Text: "",
			},
			mockSetup: func(m *mocks.MockGrammarUsecase) {
				m.On("CheckGrammar", "").Return(
					nil, assert.AnError)
			},
			expectedStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			grammarHandler := handler.NewGrammarHandler(&usecase.GrammarUsecase{}, nil)
			router := gin.New()
			router.POST("/check", grammarHandler.GrammarCheck)

			requestBody, _ := json.Marshal(tt.request)
			req := httptest.NewRequest("POST", "/check", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
			tt.mockSetup(nil) // No longer need to assert on mockUsecase
		})
	}
}
