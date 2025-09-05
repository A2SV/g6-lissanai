package entities

type GenerateEmailRequest struct {
	Prompt       string `json:"prompt" binding:"required"`
	Tone         string `json:"tone,omitempty"`
	TemplateType string `json:"template_type,omitempty" `
}

type EditEmailRequest struct {
	Draft        string `json:"draft" binding:"required"`
	Tone         string `json:"tone,omitempty"`
	TemplateType string `json:"template_type,omitempty" `
}

type EmailResponse struct {
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

type Correction struct {
	OriginalPhrase  string `json:"original_phrase"`
	CorrectedPhrase string `json:"corrected_phrase"`
	Explanation     string `json:"explanation"`
}

type EditEmailResponse struct {
	Subject     string       `json:"subject"`
	Body        string       `json:"body"`
	Corrections []Correction `json:"corrections"`
}
