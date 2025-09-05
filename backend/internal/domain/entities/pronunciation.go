package entities

// PracticeSentence is the data for the "Listen" feature, providing pre-generated audio.
type PracticeSentence struct {
	ID   string `json:"id"`
	Text string `json:"text"`
}

// PronunciationFeedback is the final, structured response for a user's attempt.
type PronunciationFeedback struct {
	OverallAccuracyScore float32  `json:"overall_accuracy_score"`
	MispronouncedWords   []string `json:"mispronouncedwords"`
	FullFeedbackSummary  string   `json:"full_feedback_summary"`
}
