// utils/test_helpers.go
package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
)

// TestRequest represents a test HTTP request
type TestRequest struct {
	Method      string
	URL         string
	Body        interface{}
	Headers     map[string]string
	QueryParams map[string]string
}

// TestResponse represents a test HTTP response
type TestResponse struct {
	StatusCode int
	Body       map[string]interface{}
	Headers    map[string]string
}

// MakeTestRequest makes an HTTP request for testing
func MakeTestRequest(t *testing.T, router *gin.Engine, req TestRequest) *httptest.ResponseRecorder {
	var body io.Reader
	if req.Body != nil {
		jsonBody, err := json.Marshal(req.Body)
		assert.NoError(t, err)
		body = bytes.NewBuffer(jsonBody)
	}

	httpReq, err := http.NewRequest(req.Method, req.URL, body)
	assert.NoError(t, err)

	// Set headers
	if req.Headers != nil {
		for key, value := range req.Headers {
			httpReq.Header.Set(key, value)
		}
	}

	// Set query parameters
	if req.QueryParams != nil {
		q := httpReq.URL.Query()
		for key, value := range req.QueryParams {
			q.Add(key, value)
		}
		httpReq.URL.RawQuery = q.Encode()
	}

	// Set default content type for JSON requests
	if req.Body != nil && httpReq.Header.Get("Content-Type") == "" {
		httpReq.Header.Set("Content-Type", "application/json")
	}

	w := httptest.NewRecorder()
	router.ServeHTTP(w, httpReq)
	return w
}

// ParseTestResponse parses the test response
func ParseTestResponse(t *testing.T, w *httptest.ResponseRecorder) TestResponse {
	var responseBody map[string]interface{}
	if w.Body.Len() > 0 {
		err := json.Unmarshal(w.Body.Bytes(), &responseBody)
		assert.NoError(t, err)
	}

	headers := make(map[string]string)
	for key, values := range w.Header() {
		if len(values) > 0 {
			headers[key] = values[0]
		}
	}

	return TestResponse{
		StatusCode: w.Code,
		Body:       responseBody,
		Headers:    headers,
	}
}

// AssertResponse asserts the test response
func AssertResponse(t *testing.T, response TestResponse, expectedStatus int, expectedFields ...string) {
	assert.Equal(t, expectedStatus, response.StatusCode)

	for _, field := range expectedFields {
		assert.Contains(t, response.Body, field, "Response should contain field: %s", field)
	}
}

// AssertErrorResponse asserts an error response
func AssertErrorResponse(t *testing.T, response TestResponse, expectedStatus int, expectedError string) {
	assert.Equal(t, expectedStatus, response.StatusCode)
	assert.Contains(t, response.Body, "error")

	if expectedError != "" {
		assert.Equal(t, expectedError, response.Body["error"])
	}
}

// AssertSuccessResponse asserts a success response
func AssertSuccessResponse(t *testing.T, response TestResponse, expectedStatus int) {
	assert.Equal(t, expectedStatus, response.StatusCode)
	assert.NotContains(t, response.Body, "error")
}

// CreateTestUser creates a test user
func CreateTestUser(t *testing.T, name, email string) *domain.User {
	return &domain.User{
		ID:           primitive.NewObjectID(),
		Name:         name,
		Email:        email,
		PasswordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy", // "password123"
		Settings: map[string]interface{}{
			"theme": "light",
		},
		CurrentStreak:    0,
		LongestStreak:    0,
		LastActivityDate: time.Time{},
		StreakFrozen:     false,
		FreezeCount:      0,
		CreatedAt:        time.Now(),
		UpdatedAt:        time.Now(),
	}
}

// CreateTestLearningPath creates a test learning path
func CreateTestLearningPath(t *testing.T, title, level, category string) *domain.LearningPath {
	return &domain.LearningPath{
		ID:          primitive.NewObjectID(),
		Title:       title,
		Description: fmt.Sprintf("Test description for %s", title),
		Level:       level,
		Category:    category,
		Duration:    60,
		LessonIDs:   []primitive.ObjectID{},
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

// CreateTestLesson creates a test lesson
func CreateTestLesson(t *testing.T, title, lessonType string, pathID primitive.ObjectID) *domain.Lesson {
	return &domain.Lesson{
		ID:          primitive.NewObjectID(),
		PathID:      pathID,
		Title:       title,
		Description: fmt.Sprintf("Test description for %s", title),
		Content:     fmt.Sprintf("Test content for %s", title),
		Type:        lessonType,
		Duration:    30,
		Order:       1,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

// CreateTestQuiz creates a test quiz
func CreateTestQuiz(t *testing.T, title string, lessonID primitive.ObjectID) *domain.Quiz {
	return &domain.Quiz{
		ID:       primitive.NewObjectID(),
		LessonID: lessonID,
		Title:    title,
		Questions: []domain.Question{
			{
				ID:      "q1",
				Text:    "Test question 1",
				Type:    "multiple_choice",
				Options: []string{"Option A", "Option B", "Option C", "Option D"},
				Correct: "Option A",
				Points:  10,
			},
		},
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// CreateTestRefreshToken creates a test refresh token
func CreateTestRefreshToken(t *testing.T, userID primitive.ObjectID, token string) *domain.RefreshToken {
	return &domain.RefreshToken{
		ID:        primitive.NewObjectID(),
		UserID:    userID,
		Token:     token,
		ExpiresAt: time.Now().AddDate(0, 0, 7), // 7 days from now
		CreatedAt: time.Now(),
	}
}

// CreateTestPasswordReset creates a test password reset
func CreateTestPasswordReset(t *testing.T, userID primitive.ObjectID, token string) *domain.PasswordReset {
	return &domain.PasswordReset{
		ID:        primitive.NewObjectID(),
		UserID:    userID,
		Token:     token,
		ExpiresAt: time.Now().AddDate(0, 0, 1), // 1 day from now
		CreatedAt: time.Now(),
		Used:      false,
	}
}

// CreateTestStreakActivity creates a test streak activity
func CreateTestStreakActivity(t *testing.T, userID primitive.ObjectID, activityType string) *domain.StreakActivity {
	return &domain.StreakActivity{
		ID:           primitive.NewObjectID(),
		UserID:       userID,
		ActivityType: activityType,
		Date:         time.Now(),
		CreatedAt:    time.Now(),
	}
}

// GenerateTestJWT generates a test JWT token
func GenerateTestJWT(t *testing.T, userID primitive.ObjectID, secret string) string {
	// This is a simplified JWT generation for testing
	// In real tests, you would use the actual JWT service
	return fmt.Sprintf("test.jwt.token.%s", userID.Hex())
}

// AssertUserEqual asserts that two users are equal (excluding timestamps)
func AssertUserEqual(t *testing.T, expected, actual *domain.User) {
	assert.Equal(t, expected.ID, actual.ID)
	assert.Equal(t, expected.Name, actual.Name)
	assert.Equal(t, expected.Email, actual.Email)
	assert.Equal(t, expected.Provider, actual.Provider)
	assert.Equal(t, expected.ProviderID, actual.ProviderID)
	assert.Equal(t, expected.Settings, actual.Settings)
	assert.Equal(t, expected.CurrentStreak, actual.CurrentStreak)
	assert.Equal(t, expected.LongestStreak, actual.LongestStreak)
	assert.Equal(t, expected.StreakFrozen, actual.StreakFrozen)
	assert.Equal(t, expected.FreezeCount, actual.FreezeCount)
}

// AssertLearningPathEqual asserts that two learning paths are equal
func AssertLearningPathEqual(t *testing.T, expected, actual *domain.LearningPath) {
	assert.Equal(t, expected.ID, actual.ID)
	assert.Equal(t, expected.Title, actual.Title)
	assert.Equal(t, expected.Description, actual.Description)
	assert.Equal(t, expected.Level, actual.Level)
	assert.Equal(t, expected.Category, actual.Category)
	assert.Equal(t, expected.Duration, actual.Duration)
	assert.Equal(t, expected.LessonIDs, actual.LessonIDs)
}

// AssertLessonEqual asserts that two lessons are equal
func AssertLessonEqual(t *testing.T, expected, actual *domain.Lesson) {
	assert.Equal(t, expected.ID, actual.ID)
	assert.Equal(t, expected.PathID, actual.PathID)
	assert.Equal(t, expected.Title, actual.Title)
	assert.Equal(t, expected.Description, actual.Description)
	assert.Equal(t, expected.Content, actual.Content)
	assert.Equal(t, expected.Type, actual.Type)
	assert.Equal(t, expected.Duration, actual.Duration)
	assert.Equal(t, expected.Order, actual.Order)
}

// AssertQuizEqual asserts that two quizzes are equal
func AssertQuizEqual(t *testing.T, expected, actual *domain.Quiz) {
	assert.Equal(t, expected.ID, actual.ID)
	assert.Equal(t, expected.LessonID, actual.LessonID)
	assert.Equal(t, expected.Title, actual.Title)
	assert.Equal(t, len(expected.Questions), len(actual.Questions))

	for i, expectedQ := range expected.Questions {
		actualQ := actual.Questions[i]
		assert.Equal(t, expectedQ.ID, actualQ.ID)
		assert.Equal(t, expectedQ.Text, actualQ.Text)
		assert.Equal(t, expectedQ.Type, actualQ.Type)
		assert.Equal(t, expectedQ.Options, actualQ.Options)
		assert.Equal(t, expectedQ.Correct, actualQ.Correct)
		assert.Equal(t, expectedQ.Points, actualQ.Points)
	}
}

// WaitForCondition waits for a condition to be true
func WaitForCondition(t *testing.T, condition func() bool, timeout time.Duration, message string) {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if condition() {
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatalf("Condition not met within timeout: %s", message)
}

// RetryOperation retries an operation until it succeeds or times out
func RetryOperation(t *testing.T, operation func() error, maxRetries int, delay time.Duration) error {
	var lastErr error
	for i := 0; i < maxRetries; i++ {
		if err := operation(); err == nil {
			return nil
		} else {
			lastErr = err
		}
		time.Sleep(delay)
	}
	return lastErr
}
