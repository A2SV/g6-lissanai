package models

type Explanation struct {
	English string `json:"english"`
	Amharic string `json:"amharic"`
}

type Correction struct {
	OriginalPhrase  string      `json:"original_phrase"`
	CorrectedPhrase string      `json:"corrected_phrase"`
	Explanation     Explanation `json:"explanation"`
}

// GrammarResponse is returned by the GrammarUsecase.
type GrammarResponse struct {
	CorrectedText string       `json:"corrected_text" example:"He has two cats"`
	Corrections   []Correction `json:"corrections"`
}
