package handler

import (
	"io/ioutil"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"lissanai.com/backend/internal/domain/interfaces"
)

type PronunciationHandler struct {
	pronunciationUC interfaces.PronunciationUsecase
}

func NewPronunciationHandler(uc interfaces.PronunciationUsecase) *PronunciationHandler {
	return &PronunciationHandler{pronunciationUC: uc}
}

// --- SWAGGER FOR GET /sentence ---

// GetSentence godoc
// @Summary      Get a practice sentence
// @Description  Dynamically generates a single, new English sentence tailored for pronunciation practice for Amharic speakers. Each request returns a unique sentence.
// @Tags         Pronunciation
// @Produce      json
// @Success      200 {object} entities.PracticeSentence
// @Failure      500 {object} object{error=string} "Returns an error if the AI service fails to generate a sentence."
// @Router       /pronunciation/sentence [get]
func (h *PronunciationHandler) GetSentences(c *gin.Context) {
	sentences, err := h.pronunciationUC.GetPracticeSentence(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate practice sentence"})
		return
	}
	c.JSON(http.StatusOK, sentences)
}

// AssessPronunciation godoc
// @Summary      Assess user's pronunciation
// @Description  Accepts a target sentence and the user's recorded audio. It analyzes the user's speech against the target text and returns detailed feedback on their pronunciation. This is a multipart/form-data request.
// @Tags         Pronunciation
// @Accept       multipart/form-data
// @Produce      json
// @Param        target_text  formData  string     true  "The exact sentence the user was asked to say."
// @Param        audio_data   formData  file       true  "The user's recorded audio file (e.g., in ogg, flac, or wav format)."
// @Success      200          {object}  entities.PronunciationFeedback
// @Failure      400          {object}  object{error=string} "Returns an error if the form data is invalid or missing."
// @Failure      500          {object}  object{error=string} "Returns an error if the AI service fails during assessment."
// @Router       /pronunciation/assess [post]
func (h *PronunciationHandler) AssessPronunciation(c *gin.Context) {
	targetText := c.PostForm("target_text")
	if targetText == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Form field 'target_text' is required"})
		return
	}

	audioFile, err := c.FormFile("audio_data")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Audio file 'audio_data' is required"})
		return
	}

	audioMimeType := audioFile.Header.Get("Content-Type")
	if audioMimeType == "" {
		// As a fallback, you could try to guess or set a default.
		// For webm/opus from the browser, this is a good default.
		audioMimeType = "audio/ogg; codecs=opus"
	}

	openedFile, err := audioFile.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open audio file"})
		return
	}
	defer openedFile.Close()

	audioData, err := ioutil.ReadAll(openedFile)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read audio file"})
		return
	}

	log.Printf("Received request to assess pronunciation for text: '%s' with audio size %d bytes.", targetText, len(audioData))

	feedback, err := h.pronunciationUC.AssessPronunciation(c.Request.Context(), targetText, audioData, audioMimeType)
	if err != nil {
		log.Printf("Error from pronunciation usecase: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to assess pronunciation"})
		return
	}

	c.JSON(http.StatusOK, feedback)
}
