// internal/usecase/learning_usecase.go
package usecase

import (
	"errors"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"lissanai.com/backend/internal/domain"
	"lissanai.com/backend/internal/repository"
)

type LearningUsecase interface {
	GetAllLearningPaths(userID primitive.ObjectID) ([]*domain.LearningPathResponse, error)
	EnrollInPath(userID primitive.ObjectID, req *domain.EnrollPathRequest) error
	GetUserProgress(userID primitive.ObjectID, pathID string) (*domain.ProgressResponse, error)
	GetLesson(userID primitive.ObjectID, lessonID string) (*domain.LessonResponse, error)
	CompleteLesson(userID primitive.ObjectID, req *domain.CompleteLessonRequest) error
	SubmitQuiz(userID primitive.ObjectID, req *domain.QuizSubmissionRequest) (*domain.QuizResultResponse, error)
}

type learningUsecase struct {
	learningRepo repository.LearningRepository
}

func NewLearningUsecase(learningRepo repository.LearningRepository) LearningUsecase {
	return &learningUsecase{
		learningRepo: learningRepo,
	}
}

func (u *learningUsecase) GetAllLearningPaths(userID primitive.ObjectID) ([]*domain.LearningPathResponse, error) {
	paths, err := u.learningRepo.GetAllLearningPaths()
	if err != nil {
		return nil, errors.New("failed to fetch learning paths")
	}

	var responses []*domain.LearningPathResponse
	for _, path := range paths {
		response := &domain.LearningPathResponse{
			LearningPath: path,
			TotalLessons: len(path.LessonIDs),
		}

		// Check if user is enrolled and get progress
		progress, err := u.learningRepo.GetUserProgress(userID, path.ID)
		if err == nil {
			response.IsEnrolled = true
			response.UserProgress = progress.Progress
			response.CompletedLessons = len(progress.CompletedLessons)
		}

		responses = append(responses, response)
	}

	return responses, nil
}

func (u *learningUsecase) EnrollInPath(userID primitive.ObjectID, req *domain.EnrollPathRequest) error {
	pathID, err := primitive.ObjectIDFromHex(req.PathID)
	if err != nil {
		return errors.New("learning path not found")
	}

	// Check if path exists
	_, err = u.learningRepo.GetLearningPathByID(pathID)
	if err != nil {
		return errors.New("learning path not found")
	}

	// Check if already enrolled
	_, err = u.learningRepo.GetUserProgress(userID, pathID)
	if err == nil {
		return errors.New("user already enrolled in this path")
	}

	// Create new progress record
	progress := &domain.UserProgress{
		UserID: userID,
		PathID: pathID,
	}

	return u.learningRepo.CreateUserProgress(progress)
}

func (u *learningUsecase) GetUserProgress(userID primitive.ObjectID, pathID string) (*domain.ProgressResponse, error) {
	pathOID, err := primitive.ObjectIDFromHex(pathID)
	if err != nil {
		return nil, errors.New("user not enrolled in this path")
	}

	progress, err := u.learningRepo.GetUserProgress(userID, pathOID)
	if err != nil {
		return nil, errors.New("user not enrolled in this path")
	}

	path, err := u.learningRepo.GetLearningPathByID(pathOID)
	if err != nil {
		return nil, errors.New("learning path not found")
	}

	return &domain.ProgressResponse{
		PathID:           pathID,
		PathTitle:        path.Title,
		Progress:         progress.Progress,
		CompletedLessons: progress.CompletedLessons,
		CurrentLesson:    progress.CurrentLesson,
		TotalLessons:     len(path.LessonIDs),
		EnrolledAt:       progress.EnrolledAt,
		LastAccessedAt:   progress.LastAccessedAt,
	}, nil
}

func (u *learningUsecase) GetLesson(userID primitive.ObjectID, lessonID string) (*domain.LessonResponse, error) {
	lessonOID, err := primitive.ObjectIDFromHex(lessonID)
	if err != nil {
		return nil, errors.New("lesson not found")
	}

	lesson, err := u.learningRepo.GetLessonByID(lessonOID)
	if err != nil {
		return nil, errors.New("lesson not found")
	}

	// Check if user is enrolled in the path
	_, err = u.learningRepo.GetUserProgress(userID, lesson.PathID)
	if err != nil {
		return nil, errors.New("user not enrolled in this learning path")
	}

	response := &domain.LessonResponse{
		Lesson: lesson,
	}

	// Check if lesson is completed
	progress, _ := u.learningRepo.GetUserProgress(userID, lesson.PathID)
	if progress != nil {
		for _, completedID := range progress.CompletedLessons {
			if completedID == lessonOID {
				response.IsCompleted = true
				break
			}
		}
	}

	// Get quiz if exists
	if lesson.QuizID != nil {
		quiz, err := u.learningRepo.GetQuizByID(*lesson.QuizID)
		if err == nil {
			// Remove correct answers from response for security
			quizCopy := *quiz
			for i := range quizCopy.Questions {
				quizCopy.Questions[i].Correct = ""
			}
			response.Quiz = &quizCopy
		}
	}

	return response, nil
}

func (u *learningUsecase) CompleteLesson(userID primitive.ObjectID, req *domain.CompleteLessonRequest) error {
	lessonOID, err := primitive.ObjectIDFromHex(req.LessonID)
	if err != nil {
		return errors.New("lesson not found")
	}

	lesson, err := u.learningRepo.GetLessonByID(lessonOID)
	if err != nil {
		return errors.New("lesson not found")
	}

	// Get user progress
	progress, err := u.learningRepo.GetUserProgress(userID, lesson.PathID)
	if err != nil {
		return errors.New("user not enrolled in this learning path")
	}

	// Check if already completed
	for _, completedID := range progress.CompletedLessons {
		if completedID == lessonOID {
			return errors.New("lesson already completed")
		}
	}

	// Add to completed lessons
	progress.CompletedLessons = append(progress.CompletedLessons, lessonOID)
	progress.CurrentLesson = &lessonOID

	// Calculate progress percentage
	path, err := u.learningRepo.GetLearningPathByID(lesson.PathID)
	if err == nil {
		progress.Progress = float64(len(progress.CompletedLessons)) / float64(len(path.LessonIDs)) * 100
	}

	return u.learningRepo.UpdateUserProgress(progress)
}

func (u *learningUsecase) SubmitQuiz(userID primitive.ObjectID, req *domain.QuizSubmissionRequest) (*domain.QuizResultResponse, error) {
	quizOID, err := primitive.ObjectIDFromHex(req.QuizID)
	if err != nil {
		return nil, errors.New("quiz not found")
	}

	quiz, err := u.learningRepo.GetQuizByID(quizOID)
	if err != nil {
		return nil, errors.New("quiz not found")
	}

	lesson, err := u.learningRepo.GetLessonByID(quiz.LessonID)
	if err != nil {
		return nil, errors.New("lesson not found")
	}

	// Check if user is enrolled
	_, err = u.learningRepo.GetUserProgress(userID, lesson.PathID)
	if err != nil {
		return nil, errors.New("user not enrolled in this learning path")
	}

	// Calculate score
	score := 0.0
	maxScore := 0
	correctAnswers := make(map[string]string)

	for _, question := range quiz.Questions {
		maxScore += question.Points
		correctAnswers[question.ID] = question.Correct

		userAnswer, exists := req.Answers[question.ID]
		if exists && userAnswer == question.Correct {
			score += float64(question.Points)
		}
	}

	percentage := (score / float64(maxScore)) * 100
	passed := percentage >= 70.0 // 70% passing grade

	// Create submission record
	submission := &domain.QuizSubmission{
		UserID:   userID,
		QuizID:   quizOID,
		LessonID: quiz.LessonID,
		Answers:  req.Answers,
		Score:    score,
		MaxScore: maxScore,
		Passed:   passed,
	}

	err = u.learningRepo.CreateQuizSubmission(submission)
	if err != nil {
		return nil, errors.New("failed to save quiz submission")
	}

	return &domain.QuizResultResponse{
		QuizID:         req.QuizID,
		LessonID:       quiz.LessonID.Hex(),
		Score:          score,
		MaxScore:       maxScore,
		Percentage:     percentage,
		Passed:         passed,
		Answers:        req.Answers,
		CorrectAnswers: correctAnswers,
		CreatedAt:      submission.CreatedAt,
	}, nil
}