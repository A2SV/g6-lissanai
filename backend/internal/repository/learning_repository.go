// internal/repository/learning_repository.go
package repository

import (
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"lissanai.com/backend/internal/domain"
)

type LearningRepository interface {
	// Learning Paths
	GetAllLearningPaths() ([]*domain.LearningPath, error)
	GetLearningPathByID(id primitive.ObjectID) (*domain.LearningPath, error)
	
	// Lessons
	GetLessonByID(id primitive.ObjectID) (*domain.Lesson, error)
	GetLessonsByPathID(pathID primitive.ObjectID) ([]*domain.Lesson, error)
	
	// Quizzes
	GetQuizByID(id primitive.ObjectID) (*domain.Quiz, error)
	GetQuizByLessonID(lessonID primitive.ObjectID) (*domain.Quiz, error)
	
	// User Progress
	GetUserProgress(userID, pathID primitive.ObjectID) (*domain.UserProgress, error)
	CreateUserProgress(progress *domain.UserProgress) error
	UpdateUserProgress(progress *domain.UserProgress) error
	GetUserProgressByPathID(userID primitive.ObjectID) ([]*domain.UserProgress, error)
	
	// Quiz Submissions
	CreateQuizSubmission(submission *domain.QuizSubmission) error
	GetQuizSubmission(userID, quizID primitive.ObjectID) (*domain.QuizSubmission, error)
}

type learningRepository struct {
	db *mongo.Database
}

func NewLearningRepository(db *mongo.Database) LearningRepository {
	return &learningRepository{db: db}
}

// Learning Paths
func (r *learningRepository) GetAllLearningPaths() ([]*domain.LearningPath, error) {
	collection := r.db.Collection("learning_paths")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var paths []*domain.LearningPath
	if err = cursor.All(ctx, &paths); err != nil {
		return nil, err
	}

	return paths, nil
}

func (r *learningRepository) GetLearningPathByID(id primitive.ObjectID) (*domain.LearningPath, error) {
	collection := r.db.Collection("learning_paths")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var path domain.LearningPath
	err := collection.FindOne(ctx, bson.M{"_id": id}).Decode(&path)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("learning path not found")
		}
		return nil, err
	}

	return &path, nil
}

// Lessons
func (r *learningRepository) GetLessonByID(id primitive.ObjectID) (*domain.Lesson, error) {
	collection := r.db.Collection("lessons")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var lesson domain.Lesson
	err := collection.FindOne(ctx, bson.M{"_id": id}).Decode(&lesson)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("lesson not found")
		}
		return nil, err
	}

	return &lesson, nil
}

func (r *learningRepository) GetLessonsByPathID(pathID primitive.ObjectID) ([]*domain.Lesson, error) {
	collection := r.db.Collection("lessons")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.Find().SetSort(bson.D{{"order", 1}})
	cursor, err := collection.Find(ctx, bson.M{"path_id": pathID}, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var lessons []*domain.Lesson
	if err = cursor.All(ctx, &lessons); err != nil {
		return nil, err
	}

	return lessons, nil
}

// Quizzes
func (r *learningRepository) GetQuizByID(id primitive.ObjectID) (*domain.Quiz, error) {
	collection := r.db.Collection("quizzes")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var quiz domain.Quiz
	err := collection.FindOne(ctx, bson.M{"_id": id}).Decode(&quiz)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("quiz not found")
		}
		return nil, err
	}

	return &quiz, nil
}

func (r *learningRepository) GetQuizByLessonID(lessonID primitive.ObjectID) (*domain.Quiz, error) {
	collection := r.db.Collection("quizzes")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var quiz domain.Quiz
	err := collection.FindOne(ctx, bson.M{"lesson_id": lessonID}).Decode(&quiz)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil // No quiz for this lesson is okay
		}
		return nil, err
	}

	return &quiz, nil
}

// User Progress
func (r *learningRepository) GetUserProgress(userID, pathID primitive.ObjectID) (*domain.UserProgress, error) {
	collection := r.db.Collection("user_progress")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var progress domain.UserProgress
	err := collection.FindOne(ctx, bson.M{"user_id": userID, "path_id": pathID}).Decode(&progress)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user progress not found")
		}
		return nil, err
	}

	return &progress, nil
}

func (r *learningRepository) CreateUserProgress(progress *domain.UserProgress) error {
	collection := r.db.Collection("user_progress")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	progress.ID = primitive.NewObjectID()
	progress.EnrolledAt = time.Now()
	progress.LastAccessedAt = time.Now()
	progress.CompletedLessons = []primitive.ObjectID{}
	progress.Progress = 0.0

	_, err := collection.InsertOne(ctx, progress)
	return err
}

func (r *learningRepository) UpdateUserProgress(progress *domain.UserProgress) error {
	collection := r.db.Collection("user_progress")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	progress.LastAccessedAt = time.Now()

	filter := bson.M{"_id": progress.ID}
	update := bson.M{"$set": progress}

	_, err := collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *learningRepository) GetUserProgressByPathID(userID primitive.ObjectID) ([]*domain.UserProgress, error) {
	collection := r.db.Collection("user_progress")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := collection.Find(ctx, bson.M{"user_id": userID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var progressList []*domain.UserProgress
	if err = cursor.All(ctx, &progressList); err != nil {
		return nil, err
	}

	return progressList, nil
}

// Quiz Submissions
func (r *learningRepository) CreateQuizSubmission(submission *domain.QuizSubmission) error {
	collection := r.db.Collection("quiz_submissions")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	submission.ID = primitive.NewObjectID()
	submission.CreatedAt = time.Now()

	_, err := collection.InsertOne(ctx, submission)
	return err
}

func (r *learningRepository) GetQuizSubmission(userID, quizID primitive.ObjectID) (*domain.QuizSubmission, error) {
	collection := r.db.Collection("quiz_submissions")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var submission domain.QuizSubmission
	err := collection.FindOne(ctx, bson.M{"user_id": userID, "quiz_id": quizID}).Decode(&submission)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("quiz submission not found")
		}
		return nil, err
	}

	return &submission, nil
}