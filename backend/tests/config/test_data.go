// config/test_data.go
package config

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
)

// TestData contains predefined test data fixtures
var TestData = struct {
	Users            []domain.User
	LearningPaths    []domain.LearningPath
	Lessons          []domain.Lesson
	Quizzes          []domain.Quiz
	RefreshTokens    []domain.RefreshToken
	PasswordResets   []domain.PasswordReset
	StreakActivities []domain.StreakActivity
}{
	Users: []domain.User{
		{
			ID:           primitive.NewObjectID(),
			Name:         "Test User 1",
			Email:        "test1@example.com",
			PasswordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy", // "password123"
			Settings: map[string]interface{}{
				"theme":    "light",
				"language": "en",
			},
			CurrentStreak:    5,
			LongestStreak:    10,
			LastActivityDate: time.Now().AddDate(0, 0, -1),
			StreakFrozen:     false,
			FreezeCount:      0,
			CreatedAt:        time.Now().AddDate(0, 0, -30),
			UpdatedAt:        time.Now().AddDate(0, 0, -1),
		},
		{
			ID:           primitive.NewObjectID(),
			Name:         "Test User 2",
			Email:        "test2@example.com",
			PasswordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy", // "password123"
			Provider:     "google",
			ProviderID:   "google_123456789",
			Settings: map[string]interface{}{
				"theme":    "dark",
				"language": "en",
			},
			CurrentStreak:    0,
			LongestStreak:    3,
			LastActivityDate: time.Now().AddDate(0, 0, -5),
			StreakFrozen:     false,
			FreezeCount:      1,
			CreatedAt:        time.Now().AddDate(0, 0, -15),
			UpdatedAt:        time.Now().AddDate(0, 0, -5),
		},
		{
			ID:           primitive.NewObjectID(),
			Name:         "Test User 3",
			Email:        "test3@example.com",
			PasswordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy", // "password123"
			Settings: map[string]interface{}{
				"theme":    "light",
				"language": "en",
			},
			CurrentStreak:    15,
			LongestStreak:    20,
			LastActivityDate: time.Now(),
			StreakFrozen:     true,
			FreezeCount:      2,
			CreatedAt:        time.Now().AddDate(0, 0, -60),
			UpdatedAt:        time.Now(),
		},
	},

	LearningPaths: []domain.LearningPath{
		{
			ID:          primitive.NewObjectID(),
			Title:       "Beginner English Grammar",
			Description: "Learn basic English grammar rules and structures",
			Level:       "beginner",
			Category:    "grammar",
			Duration:    120, // 2 hours
			LessonIDs:   []primitive.ObjectID{},
			CreatedAt:   time.Now().AddDate(0, 0, -10),
			UpdatedAt:   time.Now().AddDate(0, 0, -5),
		},
		{
			ID:          primitive.NewObjectID(),
			Title:       "Interview Preparation",
			Description: "Prepare for English job interviews",
			Level:       "intermediate",
			Category:    "speaking",
			Duration:    180, // 3 hours
			LessonIDs:   []primitive.ObjectID{},
			CreatedAt:   time.Now().AddDate(0, 0, -8),
			UpdatedAt:   time.Now().AddDate(0, 0, -3),
		},
		{
			ID:          primitive.NewObjectID(),
			Title:       "Advanced Pronunciation",
			Description: "Master English pronunciation and accent",
			Level:       "advanced",
			Category:    "pronunciation",
			Duration:    240, // 4 hours
			LessonIDs:   []primitive.ObjectID{},
			CreatedAt:   time.Now().AddDate(0, 0, -5),
			UpdatedAt:   time.Now().AddDate(0, 0, -1),
		},
	},

	Lessons: []domain.Lesson{
		{
			ID:          primitive.NewObjectID(),
			PathID:      primitive.NewObjectID(),
			Title:       "Introduction to Nouns",
			Description: "Learn about different types of nouns",
			Content:     "Nouns are words that name people, places, things, or ideas...",
			Type:        "text",
			Duration:    30,
			Order:       1,
			CreatedAt:   time.Now().AddDate(0, 0, -10),
			UpdatedAt:   time.Now().AddDate(0, 0, -5),
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      primitive.NewObjectID(),
			Title:       "Common Interview Questions",
			Description: "Practice answering common interview questions",
			Content:     "Tell me about yourself. What are your strengths? Why do you want this job?",
			Type:        "video",
			Duration:    45,
			Order:       1,
			CreatedAt:   time.Now().AddDate(0, 0, -8),
			UpdatedAt:   time.Now().AddDate(0, 0, -3),
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      primitive.NewObjectID(),
			Title:       "Vowel Sounds Practice",
			Description: "Practice English vowel sounds",
			Content:     "Focus on the difference between short and long vowel sounds...",
			Type:        "exercise",
			Duration:    60,
			Order:       1,
			CreatedAt:   time.Now().AddDate(0, 0, -5),
			UpdatedAt:   time.Now().AddDate(0, 0, -1),
		},
	},

	Quizzes: []domain.Quiz{
		{
			ID:       primitive.NewObjectID(),
			LessonID: primitive.NewObjectID(),
			Title:    "Nouns Quiz",
			Questions: []domain.Question{
				{
					ID:      "q1",
					Text:    "Which of the following is a proper noun?",
					Type:    "multiple_choice",
					Options: []string{"city", "London", "building", "street"},
					Correct: "London",
					Points:  10,
				},
				{
					ID:      "q2",
					Text:    "A noun is a word that names a person, place, thing, or idea.",
					Type:    "true_false",
					Options: []string{"True", "False"},
					Correct: "True",
					Points:  10,
				},
			},
			CreatedAt: time.Now().AddDate(0, 0, -10),
			UpdatedAt: time.Now().AddDate(0, 0, -5),
		},
	},

	RefreshTokens: []domain.RefreshToken{
		{
			ID:        primitive.NewObjectID(),
			UserID:    primitive.NewObjectID(),
			Token:     "test_refresh_token_1",
			ExpiresAt: time.Now().AddDate(0, 0, 7), // 7 days from now
			CreatedAt: time.Now().AddDate(0, 0, -1),
		},
		{
			ID:        primitive.NewObjectID(),
			UserID:    primitive.NewObjectID(),
			Token:     "test_refresh_token_2",
			ExpiresAt: time.Now().AddDate(0, 0, -1), // Expired
			CreatedAt: time.Now().AddDate(0, 0, -8),
		},
	},

	PasswordResets: []domain.PasswordReset{
		{
			ID:        primitive.NewObjectID(),
			UserID:    primitive.NewObjectID(),
			Token:     "test_reset_token_1",
			ExpiresAt: time.Now().AddDate(0, 0, 1), // 1 day from now
			CreatedAt: time.Now(),
			Used:      false,
		},
		{
			ID:        primitive.NewObjectID(),
			UserID:    primitive.NewObjectID(),
			Token:     "test_reset_token_2",
			ExpiresAt: time.Now().AddDate(0, 0, -1), // Expired
			CreatedAt: time.Now().AddDate(0, 0, -2),
			Used:      false,
		},
		{
			ID:        primitive.NewObjectID(),
			UserID:    primitive.NewObjectID(),
			Token:     "test_reset_token_3",
			ExpiresAt: time.Now().AddDate(0, 0, 1), // 1 day from now
			CreatedAt: time.Now().AddDate(0, 0, -1),
			Used:      true, // Already used
		},
	},

	StreakActivities: []domain.StreakActivity{
		{
			ID:           primitive.NewObjectID(),
			UserID:       primitive.NewObjectID(),
			ActivityType: "lesson_completed",
			Date:         time.Now().AddDate(0, 0, -1),
			CreatedAt:    time.Now().AddDate(0, 0, -1),
		},
		{
			ID:           primitive.NewObjectID(),
			UserID:       primitive.NewObjectID(),
			ActivityType: "quiz_passed",
			Date:         time.Now().AddDate(0, 0, -2),
			CreatedAt:    time.Now().AddDate(0, 0, -2),
		},
		{
			ID:           primitive.NewObjectID(),
			UserID:       primitive.NewObjectID(),
			ActivityType: "daily_goal_met",
			Date:         time.Now().AddDate(0, 0, -3),
			CreatedAt:    time.Now().AddDate(0, 0, -3),
		},
	},
}

// GetTestUser returns a test user by index
func GetTestUser(index int) *domain.User {
	if index < 0 || index >= len(TestData.Users) {
		return nil
	}
	user := TestData.Users[index]
	return &user
}

// GetTestLearningPath returns a test learning path by index
func GetTestLearningPath(index int) *domain.LearningPath {
	if index < 0 || index >= len(TestData.LearningPaths) {
		return nil
	}
	path := TestData.LearningPaths[index]
	return &path
}

// GetTestLesson returns a test lesson by index
func GetTestLesson(index int) *domain.Lesson {
	if index < 0 || index >= len(TestData.Lessons) {
		return nil
	}
	lesson := TestData.Lessons[index]
	return &lesson
}

// GetTestQuiz returns a test quiz by index
func GetTestQuiz(index int) *domain.Quiz {
	if index < 0 || index >= len(TestData.Quizzes) {
		return nil
	}
	quiz := TestData.Quizzes[index]
	return &quiz
}

// GetTestRefreshToken returns a test refresh token by index
func GetTestRefreshToken(index int) *domain.RefreshToken {
	if index < 0 || index >= len(TestData.RefreshTokens) {
		return nil
	}
	token := TestData.RefreshTokens[index]
	return &token
}

// GetTestPasswordReset returns a test password reset by index
func GetTestPasswordReset(index int) *domain.PasswordReset {
	if index < 0 || index >= len(TestData.PasswordResets) {
		return nil
	}
	reset := TestData.PasswordResets[index]
	return &reset
}

// GetTestStreakActivity returns a test streak activity by index
func GetTestStreakActivity(index int) *domain.StreakActivity {
	if index < 0 || index >= len(TestData.StreakActivities) {
		return nil
	}
	activity := TestData.StreakActivities[index]
	return &activity
}
