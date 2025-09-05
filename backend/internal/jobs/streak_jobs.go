package jobs

import (
	"context"
	"log"
	"time"

	"lissanai.com/backend/internal/service"
)

type StreakJobs struct {
	streakService *service.StreakService
}

func NewStreakJobs(streakService *service.StreakService) *StreakJobs {
	return &StreakJobs{
		streakService: streakService,
	}
}

// StartStreakMaintenance starts background jobs for streak maintenance
func (j *StreakJobs) StartStreakMaintenance(ctx context.Context) {
	// Check for expired streaks every hour
	go j.runExpiredStreakChecker(ctx)
	
	// Reset monthly freezes on the 1st of each month
	go j.runMonthlyFreezeReset(ctx)
	
	log.Println("🔥 Streak maintenance jobs started")
}

func (j *StreakJobs) runExpiredStreakChecker(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Println("Stopping expired streak checker")
			return
		case <-ticker.C:
			if err := j.streakService.CheckAndUpdateExpiredStreaks(ctx); err != nil {
				log.Printf("Error checking expired streaks: %v", err)
			}
		}
	}
}

func (j *StreakJobs) runMonthlyFreezeReset(ctx context.Context) {
	// Calculate next first of month
	now := time.Now()
	nextMonth := now.AddDate(0, 1, 0)
	firstOfNextMonth := time.Date(nextMonth.Year(), nextMonth.Month(), 1, 0, 0, 0, 0, time.UTC)
	
	// Wait until first of next month
	time.Sleep(time.Until(firstOfNextMonth))
	
	// Then run monthly
	ticker := time.NewTicker(24 * time.Hour * 30) // Approximately monthly
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Println("Stopping monthly freeze reset")
			return
		case <-ticker.C:
			// Only reset on the 1st of the month
			if time.Now().Day() == 1 {
				if err := j.streakService.ResetMonthlyFreezes(ctx); err != nil {
					log.Printf("Error resetting monthly freezes: %v", err)
				}
			}
		}
	}
}