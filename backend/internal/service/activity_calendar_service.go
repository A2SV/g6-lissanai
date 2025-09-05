package service

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/domain"
)

type ActivityCalendarService struct {
	db                   *mongo.Database
	summaryCollection    *mongo.Collection
	activityCollection   *mongo.Collection
}

func NewActivityCalendarService(db *mongo.Database) *ActivityCalendarService {
	return &ActivityCalendarService{
		db:                   db,
		summaryCollection:    db.Collection("daily_activity_summaries"),
		activityCollection:   db.Collection("streak_activities"),
	}
}

// RecordDailyActivity updates or creates a daily activity summary
func (s *ActivityCalendarService) RecordDailyActivity(ctx context.Context, userID primitive.ObjectID, activityType string, activityTime time.Time) error {
	dateStr := activityTime.Format("2006-01-02")
	
	// Check if summary exists for this date
	filter := bson.M{
		"user_id": userID,
		"date":    dateStr,
	}
	
	var existingSummary domain.DailyActivitySummary
	err := s.summaryCollection.FindOne(ctx, filter).Decode(&existingSummary)
	
	if err == mongo.ErrNoDocuments {
		// Create new daily summary
		summary := domain.DailyActivitySummary{
			ID:            primitive.NewObjectID(),
			UserID:        userID,
			Date:          dateStr,
			ActivityCount: 1,
			ActivityTypes: []string{activityType},
			FirstActivity: activityTime,
			LastActivity:  activityTime,
			CreatedAt:     time.Now(),
			UpdatedAt:     time.Now(),
		}
		
		_, err = s.summaryCollection.InsertOne(ctx, summary)
		return err
	} else if err != nil {
		return err
	}
	
	// Update existing summary
	update := bson.M{
		"$inc": bson.M{"activity_count": 1},
		"$set": bson.M{
			"last_activity": activityTime,
			"updated_at":    time.Now(),
		},
	}
	
	// Add activity type if not already present
	if !contains(existingSummary.ActivityTypes, activityType) {
		update["$addToSet"] = bson.M{"activity_types": activityType}
	}
	
	// Update first activity if this one is earlier
	if activityTime.Before(existingSummary.FirstActivity) {
		update["$set"].(bson.M)["first_activity"] = activityTime
	}
	
	_, err = s.summaryCollection.UpdateOne(ctx, filter, update)
	return err
}

// GetActivityCalendar returns a GitHub-like activity calendar for a user
func (s *ActivityCalendarService) GetActivityCalendar(ctx context.Context, userID primitive.ObjectID, year int) (*domain.ActivityCalendarResponse, error) {
	// If year is 0, use current year
	if year == 0 {
		year = time.Now().Year()
	}
	
	// Get start and end dates for the year
	startDate := time.Date(year, 1, 1, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(year+1, 1, 1, 0, 0, 0, 0, time.UTC).Add(-time.Second)
	
	// Query daily summaries for the year
	filter := bson.M{
		"user_id": userID,
		"date": bson.M{
			"$gte": startDate.Format("2006-01-02"),
			"$lte": endDate.Format("2006-01-02"),
		},
	}
	
	cursor, err := s.summaryCollection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	
	var summaries []domain.DailyActivitySummary
	if err = cursor.All(ctx, &summaries); err != nil {
		return nil, err
	}
	
	// Create a map for quick lookup
	summaryMap := make(map[string]domain.DailyActivitySummary)
	for _, summary := range summaries {
		summaryMap[summary.Date] = summary
	}
	
	// Build the calendar response
	response := &domain.ActivityCalendarResponse{
		Year:  year,
		Weeks: []domain.ActivityCalendarWeek{},
	}
	
	// Start from the first day of the year
	current := startDate
	var currentWeek domain.ActivityCalendarWeek
	totalDays := 0
	activeDays := 0
	totalActivities := 0
	activityBreakdown := make(map[string]int)
	mostActiveCount := 0
	mostActiveDay := ""
	
	// Fill in days for the entire year
	for current.Before(endDate) {
		dateStr := current.Format("2006-01-02")
		totalDays++
		
		day := domain.ActivityCalendarDay{
			Date:         dateStr,
			ActivityCount: 0,
			HasActivity:  false,
			ActivityTypes: []string{},
		}
		
		// Check if there's activity data for this day
		if summary, exists := summaryMap[dateStr]; exists {
			day.ActivityCount = summary.ActivityCount
			day.HasActivity = true
			day.ActivityTypes = summary.ActivityTypes
			activeDays++
			totalActivities += summary.ActivityCount
			
			// Update activity breakdown
			for _, actType := range summary.ActivityTypes {
				activityBreakdown[actType]++
			}
			
			// Track most active day
			if summary.ActivityCount > mostActiveCount {
				mostActiveCount = summary.ActivityCount
				mostActiveDay = dateStr
			}
		}
		
		currentWeek.Days = append(currentWeek.Days, day)
		
		// If it's Sunday or the last day of the year, complete the week
		if current.Weekday() == time.Sunday || current.Equal(endDate.Add(-24*time.Hour)) {
			response.Weeks = append(response.Weeks, currentWeek)
			currentWeek = domain.ActivityCalendarWeek{Days: []domain.ActivityCalendarDay{}}
		}
		
		current = current.Add(24 * time.Hour)
	}
	
	// Get current and longest streak from user data
	userCollection := s.db.Collection("users")
	var user domain.User
	err = userCollection.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return nil, err
	}
	
	// Calculate consecutive weeks with activity
	consecutiveWeeks := s.calculateConsecutiveWeeks(response.Weeks)
	
	// Fill in the response
	response.TotalDays = totalDays
	response.ActiveDays = activeDays
	response.CurrentStreak = user.CurrentStreak
	response.LongestStreak = user.LongestStreak
	response.Summary = domain.ActivityCalendarSummary{
		TotalActivities:   totalActivities,
		ActivityBreakdown: activityBreakdown,
		MostActiveDay:     mostActiveDay,
		MostActiveCount:   mostActiveCount,
		ConsecutiveWeeks:  consecutiveWeeks,
	}
	
	return response, nil
}

// GetActivityCalendarRange returns activity calendar for a date range
func (s *ActivityCalendarService) GetActivityCalendarRange(ctx context.Context, userID primitive.ObjectID, startDate, endDate time.Time) (*domain.ActivityCalendarResponse, error) {
	// Query daily summaries for the date range
	filter := bson.M{
		"user_id": userID,
		"date": bson.M{
			"$gte": startDate.Format("2006-01-02"),
			"$lte": endDate.Format("2006-01-02"),
		},
	}
	
	cursor, err := s.summaryCollection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	
	var summaries []domain.DailyActivitySummary
	if err = cursor.All(ctx, &summaries); err != nil {
		return nil, err
	}
	
	// Create a map for quick lookup
	summaryMap := make(map[string]domain.DailyActivitySummary)
	for _, summary := range summaries {
		summaryMap[summary.Date] = summary
	}
	
	// Build weeks starting from the start date
	response := &domain.ActivityCalendarResponse{
		Year:  startDate.Year(),
		Weeks: []domain.ActivityCalendarWeek{},
	}
	
	current := startDate
	var currentWeek domain.ActivityCalendarWeek
	totalDays := 0
	activeDays := 0
	totalActivities := 0
	activityBreakdown := make(map[string]int)
	mostActiveCount := 0
	mostActiveDay := ""
	
	for current.Before(endDate) || current.Equal(endDate) {
		dateStr := current.Format("2006-01-02")
		totalDays++
		
		day := domain.ActivityCalendarDay{
			Date:         dateStr,
			ActivityCount: 0,
			HasActivity:  false,
			ActivityTypes: []string{},
		}
		
		if summary, exists := summaryMap[dateStr]; exists {
			day.ActivityCount = summary.ActivityCount
			day.HasActivity = true
			day.ActivityTypes = summary.ActivityTypes
			activeDays++
			totalActivities += summary.ActivityCount
			
			for _, actType := range summary.ActivityTypes {
				activityBreakdown[actType]++
			}
			
			if summary.ActivityCount > mostActiveCount {
				mostActiveCount = summary.ActivityCount
				mostActiveDay = dateStr
			}
		}
		
		currentWeek.Days = append(currentWeek.Days, day)
		
		if current.Weekday() == time.Sunday || current.Equal(endDate) {
			response.Weeks = append(response.Weeks, currentWeek)
			currentWeek = domain.ActivityCalendarWeek{Days: []domain.ActivityCalendarDay{}}
		}
		
		current = current.Add(24 * time.Hour)
	}
	
	// Get streak info
	userCollection := s.db.Collection("users")
	var user domain.User
	err = userCollection.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return nil, err
	}
	
	consecutiveWeeks := s.calculateConsecutiveWeeks(response.Weeks)
	
	response.TotalDays = totalDays
	response.ActiveDays = activeDays
	response.CurrentStreak = user.CurrentStreak
	response.LongestStreak = user.LongestStreak
	response.Summary = domain.ActivityCalendarSummary{
		TotalActivities:   totalActivities,
		ActivityBreakdown: activityBreakdown,
		MostActiveDay:     mostActiveDay,
		MostActiveCount:   mostActiveCount,
		ConsecutiveWeeks:  consecutiveWeeks,
	}
	
	return response, nil
}

// Helper functions
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func (s *ActivityCalendarService) calculateConsecutiveWeeks(weeks []domain.ActivityCalendarWeek) int {
	consecutive := 0
	maxConsecutive := 0
	
	for _, week := range weeks {
		hasActivity := false
		for _, day := range week.Days {
			if day.HasActivity {
				hasActivity = true
				break
			}
		}
		
		if hasActivity {
			consecutive++
			if consecutive > maxConsecutive {
				maxConsecutive = consecutive
			}
		} else {
			consecutive = 0
		}
	}
	
	return maxConsecutive
}