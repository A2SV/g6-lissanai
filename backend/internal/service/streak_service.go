package service

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/domain"
)

type StreakService struct {
	userCollection     *mongo.Collection
	activityCollection *mongo.Collection
	calendarService    *ActivityCalendarService
}

func NewStreakService(db *mongo.Database) *StreakService {
	calendarService := NewActivityCalendarService(db)
	return &StreakService{
		userCollection:     db.Collection("users"),
		activityCollection: db.Collection("streak_activities"),
		calendarService:    calendarService,
	}
}

// RecordActivity records a user activity and updates their streak
func (s *StreakService) RecordActivity(ctx context.Context, userID primitive.ObjectID, activityType string) error {
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)

	// Check if user already has activity today
	existingActivity, err := s.activityCollection.CountDocuments(ctx, bson.M{
		"user_id": userID,
		"date": bson.M{
			"$gte": today,
			"$lt":  today.Add(24 * time.Hour),
		},
	})
	if err != nil {
		return fmt.Errorf("failed to check existing activity: %w", err)
	}

	// Record the activity
	activity := domain.StreakActivity{
		UserID:       userID,
		ActivityType: activityType,
		Date:         today,
		CreatedAt:    now,
	}

	_, err = s.activityCollection.InsertOne(ctx, activity)
	if err != nil {
		return fmt.Errorf("failed to record activity: %w", err)
	}

	// Record activity in calendar service for GitHub-like visualization
	if err := s.calendarService.RecordDailyActivity(ctx, userID, activityType, now); err != nil {
		log.Printf("Failed to record daily activity for user %s: %v", userID.Hex(), err)
		// Don't fail the main operation if calendar recording fails
	}

	// Update streak only if this is the first activity today
	if existingActivity == 0 {
		return s.updateStreak(ctx, userID, today)
	}

	return nil
}

// updateStreak calculates and updates the user's streak
func (s *StreakService) updateStreak(ctx context.Context, userID primitive.ObjectID, activityDate time.Time) error {
	var user domain.User
	err := s.userCollection.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return fmt.Errorf("failed to find user: %w", err)
	}

	yesterday := activityDate.Add(-24 * time.Hour)
	lastActivityDate := time.Date(user.LastActivityDate.Year(), user.LastActivityDate.Month(), user.LastActivityDate.Day(), 0, 0, 0, 0, time.UTC)

	var newStreak int
	streakBroken := false

	if user.LastActivityDate.IsZero() {
		// First activity ever
		newStreak = 1
	} else if lastActivityDate.Equal(yesterday) {
		// Consecutive day
		newStreak = user.CurrentStreak + 1
	} else if lastActivityDate.Equal(activityDate) {
		// Same day (shouldn't happen due to check above, but just in case)
		newStreak = user.CurrentStreak
	} else if user.StreakFrozen && lastActivityDate.Before(yesterday) {
		// Streak was frozen, continue from where we left off
		newStreak = user.CurrentStreak + 1
		user.StreakFrozen = false // Unfreeze after activity
	} else {
		// Streak broken
		newStreak = 1
		streakBroken = true
		log.Printf("Streak broken for user %s. Last activity: %v, Current activity: %v", userID.Hex(), lastActivityDate, activityDate)
	}

	// Update longest streak if current streak is higher
	longestStreak := user.LongestStreak
	if newStreak > longestStreak {
		longestStreak = newStreak
	}

	// Update user
	update := bson.M{
		"$set": bson.M{
			"current_streak":      newStreak,
			"longest_streak":      longestStreak,
			"last_activity_date":  activityDate,
			"streak_frozen":       false, // Always unfreeze on activity
			"updated_at":          time.Now(),
		},
	}

	_, err = s.userCollection.UpdateOne(ctx, bson.M{"_id": userID}, update)
	if err != nil {
		return fmt.Errorf("failed to update user streak: %w", err)
	}

	// Log streak milestone
	if newStreak > 0 && newStreak%7 == 0 {
		log.Printf("🔥 User %s reached %d day streak milestone!", userID.Hex(), newStreak)
	}

	if streakBroken && user.CurrentStreak > 1 {
		log.Printf("💔 User %s lost their %d day streak", userID.Hex(), user.CurrentStreak)
	}

	return nil
}

// GetStreakInfo returns the user's current streak information
func (s *StreakService) GetStreakInfo(ctx context.Context, userID primitive.ObjectID) (*domain.StreakInfo, error) {
	var user domain.User
	err := s.userCollection.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return nil, fmt.Errorf("failed to find user: %w", err)
	}

	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	lastActivityDate := time.Date(user.LastActivityDate.Year(), user.LastActivityDate.Month(), user.LastActivityDate.Day(), 0, 0, 0, 0, time.UTC)

	// Calculate days until streak loss
	daysUntilLoss := 0
	if !user.LastActivityDate.IsZero() && !user.StreakFrozen {
		daysSinceActivity := int(today.Sub(lastActivityDate).Hours() / 24)
		if daysSinceActivity >= 1 {
			daysUntilLoss = 0 // Already lost or about to lose
		} else {
			daysUntilLoss = 1 - daysSinceActivity
		}
	}

	// Check if user can freeze (max 2 freezes per month)
	maxFreezes := 2
	canFreeze := user.FreezeCount < maxFreezes && user.CurrentStreak > 0 && !user.StreakFrozen

	return &domain.StreakInfo{
		CurrentStreak:    user.CurrentStreak,
		LongestStreak:    user.LongestStreak,
		LastActivityDate: user.LastActivityDate,
		StreakFrozen:     user.StreakFrozen,
		FreezeCount:      user.FreezeCount,
		MaxFreezes:       maxFreezes,
		CanFreeze:        canFreeze,
		DaysUntilLoss:    daysUntilLoss,
	}, nil
}

// FreezeStreak freezes the user's streak for one day
func (s *StreakService) FreezeStreak(ctx context.Context, userID primitive.ObjectID, reason string) error {
	var user domain.User
	err := s.userCollection.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return fmt.Errorf("failed to find user: %w", err)
	}

	// Check if user can freeze
	if user.FreezeCount >= 2 {
		return fmt.Errorf("maximum freeze limit reached for this month")
	}

	if user.CurrentStreak == 0 {
		return fmt.Errorf("cannot freeze a streak of 0 days")
	}

	if user.StreakFrozen {
		return fmt.Errorf("streak is already frozen")
	}

	// Update user
	update := bson.M{
		"$set": bson.M{
			"streak_frozen": true,
			"updated_at":    time.Now(),
		},
		"$inc": bson.M{
			"freeze_count": 1,
		},
	}

	_, err = s.userCollection.UpdateOne(ctx, bson.M{"_id": userID}, update)
	if err != nil {
		return fmt.Errorf("failed to freeze streak: %w", err)
	}

	log.Printf("🧊 User %s froze their %d day streak. Reason: %s", userID.Hex(), user.CurrentStreak, reason)
	return nil
}

// ResetMonthlyFreezes resets the freeze count for all users (should be called monthly)
func (s *StreakService) ResetMonthlyFreezes(ctx context.Context) error {
	result, err := s.userCollection.UpdateMany(ctx, bson.M{}, bson.M{
		"$set": bson.M{
			"freeze_count": 0,
			"updated_at":   time.Now(),
		},
	})
	if err != nil {
		return fmt.Errorf("failed to reset monthly freezes: %w", err)
	}

	log.Printf("🔄 Reset freeze count for %d users", result.ModifiedCount)
	return nil
}

// CheckAndUpdateExpiredStreaks checks for users whose streaks should be reset due to inactivity
func (s *StreakService) CheckAndUpdateExpiredStreaks(ctx context.Context) error {
	now := time.Now()
	yesterday := time.Date(now.Year(), now.Month(), now.Day()-1, 0, 0, 0, 0, time.UTC)

	// Find users whose streaks should be reset (no activity yesterday and not frozen)
	cursor, err := s.userCollection.Find(ctx, bson.M{
		"current_streak": bson.M{"$gt": 0},
		"last_activity_date": bson.M{"$lt": yesterday},
		"streak_frozen": false,
	})
	if err != nil {
		return fmt.Errorf("failed to find users with expired streaks: %w", err)
	}
	defer cursor.Close(ctx)

	var expiredCount int
	for cursor.Next(ctx) {
		var user domain.User
		if err := cursor.Decode(&user); err != nil {
			log.Printf("Error decoding user: %v", err)
			continue
		}

		// Reset streak to 0
		_, err := s.userCollection.UpdateOne(ctx, bson.M{"_id": user.ID}, bson.M{
			"$set": bson.M{
				"current_streak": 0,
				"updated_at":     now,
			},
		})
		if err != nil {
			log.Printf("Error resetting streak for user %s: %v", user.ID.Hex(), err)
			continue
		}

		log.Printf("💔 Reset expired streak for user %s (was %d days)", user.ID.Hex(), user.CurrentStreak)
		expiredCount++
	}

	if expiredCount > 0 {
		log.Printf("🔄 Reset streaks for %d users due to inactivity", expiredCount)
	}

	return nil
}

// GetActivityCalendar returns the GitHub-like activity calendar for a user
func (s *StreakService) GetActivityCalendar(ctx context.Context, userID primitive.ObjectID, year int) (*domain.ActivityCalendarResponse, error) {
	return s.calendarService.GetActivityCalendar(ctx, userID, year)
}

// GetActivityCalendarRange returns activity calendar for a specific date range
func (s *StreakService) GetActivityCalendarRange(ctx context.Context, userID primitive.ObjectID, startDate, endDate time.Time) (*domain.ActivityCalendarResponse, error) {
	return s.calendarService.GetActivityCalendarRange(ctx, userID, startDate, endDate)
}