// scripts/seed_learning_data.go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/database"
	"lissanai.com/backend/internal/domain"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Connect to database
	db, err := database.NewMongoConnection()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	fmt.Println("🌱 Seeding learning data...")

	// Create learning paths
	paths := createLearningPaths()
	pathIDs := make(map[string]primitive.ObjectID)
	for _, path := range paths {
		_, err := db.Collection("learning_paths").InsertOne(context.Background(), path)
		if err != nil {
			log.Printf("Failed to insert learning path %s: %v", path.Title, err)
			continue
		}
		pathIDs[path.Title] = path.ID
		fmt.Printf("✅ Created learning path: %s\n", path.Title)
	}

	// Create lessons
	lessons := createLessons(paths)
	lessonsByPath := make(map[primitive.ObjectID][]primitive.ObjectID)
	for _, lesson := range lessons {
		_, err := db.Collection("lessons").InsertOne(context.Background(), lesson)
		if err != nil {
			log.Printf("Failed to insert lesson %s: %v", lesson.Title, err)
			continue
		}
		lessonsByPath[lesson.PathID] = append(lessonsByPath[lesson.PathID], lesson.ID)
		fmt.Printf("✅ Created lesson: %s\n", lesson.Title)
	}

	// Update learning paths with lesson IDs
	for pathTitle, pathID := range pathIDs {
		if lessonIDs, exists := lessonsByPath[pathID]; exists {
			_, err := db.Collection("learning_paths").UpdateOne(
				context.Background(),
				primitive.M{"_id": pathID},
				primitive.M{"$set": primitive.M{"lesson_ids": lessonIDs}},
			)
			if err != nil {
				log.Printf("Failed to update learning path %s with lessons: %v", pathTitle, err)
			} else {
				fmt.Printf("🔗 Updated %s with %d lessons\n", pathTitle, len(lessonIDs))
			}
		}
	}

	// Create quizzes
	quizzes := createQuizzes(lessons)
	for _, quiz := range quizzes {
		_, err := db.Collection("quizzes").InsertOne(context.Background(), quiz)
		if err != nil {
			log.Printf("Failed to insert quiz %s: %v", quiz.Title, err)
			continue
		}
		fmt.Printf("✅ Created quiz: %s\n", quiz.Title)
	}

	fmt.Println("🎉 Learning data seeding completed!")
}

func createLearningPaths() []*domain.LearningPath {
	now := time.Now()
	return []*domain.LearningPath{
		{
			ID:          primitive.NewObjectID(),
			Title:       "English Grammar Fundamentals",
			Description: "Master the basics of English grammar with interactive lessons and exercises.",
			Level:       "beginner",
			Category:    "grammar",
			Duration:    180, // 3 hours
			LessonIDs:   []primitive.ObjectID{}, // Will be populated later
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			Title:       "Business English Communication",
			Description: "Learn professional English communication skills for the workplace.",
			Level:       "intermediate",
			Category:    "business",
			Duration:    240, // 4 hours
			LessonIDs:   []primitive.ObjectID{},
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			Title:       "IELTS Speaking Preparation",
			Description: "Comprehensive preparation for the IELTS speaking test with practice sessions.",
			Level:       "advanced",
			Category:    "test-prep",
			Duration:    300, // 5 hours
			LessonIDs:   []primitive.ObjectID{},
			CreatedAt:   now,
			UpdatedAt:   now,
		},
	}
}

func createLessons(paths []*domain.LearningPath) []*domain.Lesson {
	now := time.Now()
	var lessons []*domain.Lesson

	// Grammar Fundamentals lessons
	grammarPath := paths[0]
	grammarLessons := []*domain.Lesson{
		{
			ID:          primitive.NewObjectID(),
			PathID:      grammarPath.ID,
			Title:       "Parts of Speech",
			Description: "Learn about nouns, verbs, adjectives, and other parts of speech.",
			Content:     "In this lesson, we'll explore the fundamental building blocks of English grammar: parts of speech. Understanding these categories will help you construct clear and effective sentences.",
			Type:        "text",
			Duration:    30,
			Order:       1,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      grammarPath.ID,
			Title:       "Sentence Structure",
			Description: "Master the basics of English sentence construction.",
			Content:     "Learn how to build proper sentences using subjects, predicates, and objects. We'll cover simple, compound, and complex sentence structures.",
			Type:        "video",
			Duration:    45,
			Order:       2,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      grammarPath.ID,
			Title:       "Verb Tenses",
			Description: "Understanding past, present, and future tenses.",
			Content:     "Explore the English tense system, including simple, continuous, perfect, and perfect continuous forms.",
			Type:        "quiz",
			Duration:    60,
			Order:       3,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
	}

	// Business English lessons
	businessPath := paths[1]
	businessLessons := []*domain.Lesson{
		{
			ID:          primitive.NewObjectID(),
			PathID:      businessPath.ID,
			Title:       "Professional Email Writing",
			Description: "Learn to write clear and professional business emails.",
			Content:     "Master the art of business email communication, including proper formatting, tone, and etiquette.",
			Type:        "text",
			Duration:    40,
			Order:       1,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      businessPath.ID,
			Title:       "Meeting Participation",
			Description: "Effective communication in business meetings.",
			Content:     "Learn how to participate confidently in meetings, present ideas clearly, and engage in professional discussions.",
			Type:        "video",
			Duration:    50,
			Order:       2,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
	}

	// IELTS Speaking lessons
	ieltsPath := paths[2]
	ieltsLessons := []*domain.Lesson{
		{
			ID:          primitive.NewObjectID(),
			PathID:      ieltsPath.ID,
			Title:       "IELTS Speaking Part 1",
			Description: "Introduction and interview questions preparation.",
			Content:     "Practice common Part 1 questions about yourself, your home, work, studies, and familiar topics.",
			Type:        "exercise",
			Duration:    60,
			Order:       1,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		{
			ID:          primitive.NewObjectID(),
			PathID:      ieltsPath.ID,
			Title:       "IELTS Speaking Part 2",
			Description: "Long turn speaking task preparation.",
			Content:     "Learn strategies for the 2-minute speaking task, including how to structure your response and use the preparation time effectively.",
			Type:        "video",
			Duration:    75,
			Order:       2,
			CreatedAt:   now,
			UpdatedAt:   now,
		},
	}

	lessons = append(lessons, grammarLessons...)
	lessons = append(lessons, businessLessons...)
	lessons = append(lessons, ieltsLessons...)

	// Update learning paths with lesson IDs
	for i, lesson := range grammarLessons {
		paths[0].LessonIDs = append(paths[0].LessonIDs, lesson.ID)
		if i == 2 { // Verb Tenses lesson has a quiz
			quizID := primitive.NewObjectID()
			lesson.QuizID = &quizID
		}
	}

	for _, lesson := range businessLessons {
		paths[1].LessonIDs = append(paths[1].LessonIDs, lesson.ID)
	}

	for _, lesson := range ieltsLessons {
		paths[2].LessonIDs = append(paths[2].LessonIDs, lesson.ID)
	}

	return lessons
}

func createQuizzes(lessons []*domain.Lesson) []*domain.Quiz {
	now := time.Now()
	var quizzes []*domain.Quiz

	// Find the Verb Tenses lesson (has quiz)
	for _, lesson := range lessons {
		if lesson.Title == "Verb Tenses" && lesson.QuizID != nil {
			quiz := &domain.Quiz{
				ID:       *lesson.QuizID,
				LessonID: lesson.ID,
				Title:    "Verb Tenses Quiz",
				Questions: []domain.Question{
					{
						ID:      "q1",
						Text:    "Which sentence uses the present perfect tense correctly?",
						Type:    "multiple_choice",
						Options: []string{"I have seen that movie", "I saw that movie", "I am seeing that movie", "I will see that movie"},
						Correct: "I have seen that movie",
						Points:  10,
					},
					{
						ID:      "q2",
						Text:    "The past continuous tense is used to describe ongoing actions in the past.",
						Type:    "true_false",
						Options: []string{"True", "False"},
						Correct: "True",
						Points:  5,
					},
					{
						ID:      "q3",
						Text:    "Complete the sentence: By next year, I _____ my degree.",
						Type:    "multiple_choice",
						Options: []string{"will complete", "will have completed", "complete", "am completing"},
						Correct: "will have completed",
						Points:  15,
					},
				},
				CreatedAt: now,
				UpdatedAt: now,
			}
			quizzes = append(quizzes, quiz)
			break
		}
	}

	return quizzes
}