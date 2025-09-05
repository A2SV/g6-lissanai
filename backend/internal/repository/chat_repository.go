package repository

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/domain/models"
)

type MongoSessionRepo struct {
	collection *mongo.Collection
}

func NewMongoSessionRepo(db *mongo.Database) *MongoSessionRepo {
	return &MongoSessionRepo{collection: db.Collection("sessions")}
}

func (r *MongoSessionRepo) CreateSession(session *models.Session) error {
	session.CreatedAt = time.Now()
	session.UpdatedAt = time.Now()
	_, err := r.collection.InsertOne(context.Background(), session)
	return err
}

func (r *MongoSessionRepo) GetSessionByID(sessionID string) (*models.Session, error) {
	var session models.Session
	err := r.collection.FindOne(context.Background(), bson.M{"_id": sessionID}).Decode(&session)
	return &session, err
}

func (r *MongoSessionRepo) UpdateSessionProgress(sessionID string, completedQuestions int, score int) error {
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": sessionID},
		bson.M{"$set": bson.M{
			"completed_questions": completedQuestions,
			"score_percentage":    score,
			"updated_at":          time.Now(),
		}},
	)
	return err
}

func (r *MongoSessionRepo) DeleteSession(sessionID string) error {
	_, err := r.collection.DeleteOne(context.Background(), bson.M{"_id": sessionID})
	return err
}

type MongoMessageRepo struct {
	collection *mongo.Collection
}

func NewMongoMessageRepo(db *mongo.Database) *MongoMessageRepo {
	return &MongoMessageRepo{collection: db.Collection("messages")}
}

func (r *MongoMessageRepo) AddMessage(msg *models.Message) error {
	msg.CreatedAt = time.Now()
	_, err := r.collection.InsertOne(context.Background(), msg)
	return err
}

func (r *MongoMessageRepo) GetMessagesBySession(sessionID string) ([]*models.Message, error) {
	cursor, err := r.collection.Find(context.Background(), bson.M{"session_id": sessionID})
	if err != nil {
		return nil, err
	}
	var messages []*models.Message
	if err := cursor.All(context.Background(), &messages); err != nil {
		return nil, err
	}
	return messages, nil
}

func (r *MongoMessageRepo) GetMessageByID(messageID string) (*models.Message, error) {
	var msg models.Message
	objID, _ := primitive.ObjectIDFromHex(messageID)
	err := r.collection.FindOne(context.Background(), bson.M{"_id": objID}).Decode(&msg)
	return &msg, err
}

func (r *MongoMessageRepo) UpdateMessageFeedback(messageID string, feedback *models.Feedback) error {
	objID, _ := primitive.ObjectIDFromHex(messageID)
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": objID},
		bson.M{"$set": bson.M{"feedback": feedback}},
	)
	return err
}

func (r *MongoMessageRepo) DeleteMessagesBySession(sessionID string) error {
	_, err := r.collection.DeleteMany(context.Background(), bson.M{"session_id": sessionID})
	return err
}
