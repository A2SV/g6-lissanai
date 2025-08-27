package entities

type EmailRequest struct {
	Type         string `json:"type"`
	Prompt       string `json:"prompt" binding:"required"`
	Tone         string `json:"tone,omitempty"`
	TemplateType string `json:"template_type,omitempty" `
}
type EmailResponse struct {
	Subject        string `json:"subject"`
	GeneratedEmail string `json:"generated_email"`
}
