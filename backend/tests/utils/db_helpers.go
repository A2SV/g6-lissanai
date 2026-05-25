// utils/db_helpers.go
package utils

import (
	"context"
	"testing"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/domain"
)

// DatabaseHelper provides helper functions for database operations in tests
type DatabaseHelper struct {
	DB *mongo.Database
}

// NewDatabaseHelper creates a new database helper
func NewDatabaseHelper(db *mongo.Database) *DatabaseHelper {
	return &DatabaseHelper{DB: db}
}

// CleanupCollections cleans up all test collections
func (h *DatabaseHelper) CleanupCollections(t *testing.T) {
	collections := []string{
		"users",
		"refresh_tokens",
		"password_resets",
		"learning_paths",
		"lessons",
		"quizzes",
		"user_progress",
		"quiz_submissions",
		"streak_activities",
		"daily_activity_summaries",
		"chat_sessions",
		"chat_messages",
		"pronunciation_activities",
		"email_drafts",
	}

	for _, collection := range collections {
		if err := h.DB.Collection(collection).Drop(context.Background()); err != nil {
			t.Logf("Warning: Failed to drop collection %s: %v", collection, err)
		}
	}
}

// InsertUser inserts a user into the database
func (h *DatabaseHelper) InsertUser(t *testing.T, user *domain.User) *domain.User {
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()

	result, err := h.DB.Collection("users").InsertOne(context.Background(), user)
	if err != nil {
		t.Fatalf("Failed to insert user: %v", err)
	}

	user.ID = result.InsertedID.(primitive.ObjectID)
	return user
}

// InsertUsers inserts multiple users into the database
func (h *DatabaseHelper) InsertUsers(t *testing.T, users []domain.User) []domain.User {
	insertedUsers := make([]domain.User, len(users))
	for i, user := range users {
		insertedUsers[i] = *h.InsertUser(t, &user)
	}
	return insertedUsers
}

// GetUserByID gets a user by ID
func (h *DatabaseHelper) GetUserByID(t *testing.T, userID primitive.ObjectID) *domain.User {
	var user domain.User
	err := h.DB.Collection("users").FindOne(context.Background(), bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get user by ID: %v", err)
	}
	return &user
}

// GetUserByEmail gets a user by email
func (h *DatabaseHelper) GetUserByEmail(t *testing.T, email string) *domain.User {
	var user domain.User
	err := h.DB.Collection("users").FindOne(context.Background(), bson.M{"email": email}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get user by email: %v", err)
	}
	return &user
}

// UpdateUser updates a user in the database
func (h *DatabaseHelper) UpdateUser(t *testing.T, user *domain.User) {
	user.UpdatedAt = time.Now()

	_, err := h.DB.Collection("users").ReplaceOne(
		context.Background(),
		bson.M{"_id": user.ID},
		user,
	)
	if err != nil {
		t.Fatalf("Failed to update user: %v", err)
	}
}

// DeleteUser deletes a user from the database
func (h *DatabaseHelper) DeleteUser(t *testing.T, userID primitive.ObjectID) {
	_, err := h.DB.Collection("users").DeleteOne(context.Background(), bson.M{"_id": userID})
	if err != nil {
		t.Fatalf("Failed to delete user: %v", err)
	}
}

// InsertLearningPath inserts a learning path into the database
func (h *DatabaseHelper) InsertLearningPath(t *testing.T, path *domain.LearningPath) *domain.LearningPath {
	path.CreatedAt = time.Now()
	path.UpdatedAt = time.Now()

	result, err := h.DB.Collection("learning_paths").InsertOne(context.Background(), path)
	if err != nil {
		t.Fatalf("Failed to insert learning path: %v", err)
	}

	path.ID = result.InsertedID.(primitive.ObjectID)
	return path
}

// GetLearningPathByID gets a learning path by ID
func (h *DatabaseHelper) GetLearningPathByID(t *testing.T, pathID primitive.ObjectID) *domain.LearningPath {
	var path domain.LearningPath
	err := h.DB.Collection("learning_paths").FindOne(context.Background(), bson.M{"_id": pathID}).Decode(&path)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get learning path by ID: %v", err)
	}
	return &path
}

// InsertLesson inserts a lesson into the database
func (h *DatabaseHelper) InsertLesson(t *testing.T, lesson *domain.Lesson) *domain.Lesson {
	lesson.CreatedAt = time.Now()
	lesson.UpdatedAt = time.Now()

	result, err := h.DB.Collection("lessons").InsertOne(context.Background(), lesson)
	if err != nil {
		t.Fatalf("Failed to insert lesson: %v", err)
	}

	lesson.ID = result.InsertedID.(primitive.ObjectID)
	return lesson
}

// GetLessonByID gets a lesson by ID
func (h *DatabaseHelper) GetLessonByID(t *testing.T, lessonID primitive.ObjectID) *domain.Lesson {
	var lesson domain.Lesson
	err := h.DB.Collection("lessons").FindOne(context.Background(), bson.M{"_id": lessonID}).Decode(&lesson)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get lesson by ID: %v", err)
	}
	return &lesson
}

// InsertQuiz inserts a quiz into the database
func (h *DatabaseHelper) InsertQuiz(t *testing.T, quiz *domain.Quiz) *domain.Quiz {
	quiz.CreatedAt = time.Now()
	quiz.UpdatedAt = time.Now()

	result, err := h.DB.Collection("quizzes").InsertOne(context.Background(), quiz)
	if err != nil {
		t.Fatalf("Failed to insert quiz: %v", err)
	}

	quiz.ID = result.InsertedID.(primitive.ObjectID)
	return quiz
}

// GetQuizByID gets a quiz by ID
func (h *DatabaseHelper) GetQuizByID(t *testing.T, quizID primitive.ObjectID) *domain.Quiz {
	var quiz domain.Quiz
	err := h.DB.Collection("quizzes").FindOne(context.Background(), bson.M{"_id": quizID}).Decode(&quiz)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get quiz by ID: %v", err)
	}
	return &quiz
}

// InsertRefreshToken inserts a refresh token into the database
func (h *DatabaseHelper) InsertRefreshToken(t *testing.T, token *domain.RefreshToken) *domain.RefreshToken {
	token.CreatedAt = time.Now()

	result, err := h.DB.Collection("refresh_tokens").InsertOne(context.Background(), token)
	if err != nil {
		t.Fatalf("Failed to insert refresh token: %v", err)
	}

	token.ID = result.InsertedID.(primitive.ObjectID)
	return token
}

// GetRefreshToken gets a refresh token by token string
func (h *DatabaseHelper) GetRefreshToken(t *testing.T, token string) *domain.RefreshToken {
	var refreshToken domain.RefreshToken
	err := h.DB.Collection("refresh_tokens").FindOne(context.Background(), bson.M{"token": token}).Decode(&refreshToken)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get refresh token: %v", err)
	}
	return &refreshToken
}

// DeleteRefreshToken deletes a refresh token from the database
func (h *DatabaseHelper) DeleteRefreshToken(t *testing.T, token string) {
	_, err := h.DB.Collection("refresh_tokens").DeleteOne(context.Background(), bson.M{"token": token})
	if err != nil {
		t.Fatalf("Failed to delete refresh token: %v", err)
	}
}

// InsertPasswordReset inserts a password reset into the database
func (h *DatabaseHelper) InsertPasswordReset(t *testing.T, reset *domain.PasswordReset) *domain.PasswordReset {
	reset.CreatedAt = time.Now()

	result, err := h.DB.Collection("password_resets").InsertOne(context.Background(), reset)
	if err != nil {
		t.Fatalf("Failed to insert password reset: %v", err)
	}

	reset.ID = result.InsertedID.(primitive.ObjectID)
	return reset
}

// GetPasswordReset gets a password reset by token
func (h *DatabaseHelper) GetPasswordReset(t *testing.T, token string) *domain.PasswordReset {
	var reset domain.PasswordReset
	err := h.DB.Collection("password_resets").FindOne(context.Background(), bson.M{"token": token}).Decode(&reset)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil
		}
		t.Fatalf("Failed to get password reset: %v", err)
	}
	return &reset
}

// InsertStreakActivity inserts a streak activity into the database
func (h *DatabaseHelper) InsertStreakActivity(t *testing.T, activity *domain.StreakActivity) *domain.StreakActivity {
	activity.CreatedAt = time.Now()

	result, err := h.DB.Collection("streak_activities").InsertOne(context.Background(), activity)
	if err != nil {
		t.Fatalf("Failed to insert streak activity: %v", err)
	}

	activity.ID = result.InsertedID.(primitive.ObjectID)
	return activity
}

// GetStreakActivitiesByUserID gets streak activities for a user
func (h *DatabaseHelper) GetStreakActivitiesByUserID(t *testing.T, userID primitive.ObjectID) []domain.StreakActivity {
	cursor, err := h.DB.Collection("streak_activities").Find(
		context.Background(),
		bson.M{"user_id": userID},
	)
	if err != nil {
		t.Fatalf("Failed to get streak activities: %v", err)
	}
	defer cursor.Close(context.Background())

	var activities []domain.StreakActivity
	if err := cursor.All(context.Background(), &activities); err != nil {
		t.Fatalf("Failed to decode streak activities: %v", err)
	}
	return activities
}

// CountDocuments counts documents in a collection
func (h *DatabaseHelper) CountDocuments(t *testing.T, collection string, filter bson.M) int64 {
	count, err := h.DB.Collection(collection).CountDocuments(context.Background(), filter)
	if err != nil {
		t.Fatalf("Failed to count documents in %s: %v", collection, err)
	}
	return count
}

// AssertDocumentExists asserts that a document exists in a collection
func (h *DatabaseHelper) AssertDocumentExists(t *testing.T, collection string, filter bson.M) {
	count := h.CountDocuments(t, collection, filter)
	if count == 0 {
		t.Fatalf("Expected document to exist in %s with filter %v", collection, filter)
	}
}

// AssertDocumentNotExists asserts that a document does not exist in a collection
func (h *DatabaseHelper) AssertDocumentNotExists(t *testing.T, collection string, filter bson.M) {
	count := h.CountDocuments(t, collection, filter)
	if count > 0 {
		t.Fatalf("Expected document to not exist in %s with filter %v", collection, filter)
	}
}

// AssertDocumentCount asserts the count of documents in a collection
func (h *DatabaseHelper) AssertDocumentCount(t *testing.T, collection string, filter bson.M, expectedCount int64) {
	actualCount := h.CountDocuments(t, collection, filter)
	if actualCount != expectedCount {
		t.Fatalf("Expected %d documents in %s, got %d", expectedCount, collection, actualCount)
	}
}
