// internal/repository/user_repository.go
package repository

import (
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"lissanai.com/backend/internal/domain"
)

type UserRepository interface {
	CreateUser(user *domain.User) (*domain.User, error)
	GetUserByEmail(email string) (*domain.User, error)
	GetUserByID(id primitive.ObjectID) (*domain.User, error)
	GetUserByProviderID(provider, providerID string) (*domain.User, error)
	UpdateUser(user *domain.User) error
	DeleteUser(id primitive.ObjectID) error
	AddPushToken(userID primitive.ObjectID, pushToken domain.PushToken) error
	RemovePushToken(userID primitive.ObjectID, token string) error
}

type RefreshTokenRepository interface {
	CreateRefreshToken(token *domain.RefreshToken) error
	GetRefreshToken(token string) (*domain.RefreshToken, error)
	DeleteRefreshToken(token string) error
	DeleteUserRefreshTokens(userID primitive.ObjectID) error
}

type PasswordResetRepository interface {
	CreatePasswordReset(reset *domain.PasswordReset) error
	GetPasswordReset(token string) (*domain.PasswordReset, error)
	MarkPasswordResetUsed(token string) error
	DeleteExpiredResets() error
}

type userRepository struct {
	db         *mongo.Database
	collection *mongo.Collection
}

type refreshTokenRepository struct {
	db         *mongo.Database
	collection *mongo.Collection
}

type passwordResetRepository struct {
	db         *mongo.Database
	collection *mongo.Collection
}

func NewUserRepository(db *mongo.Database) UserRepository {
	return &userRepository{
		db:         db,
		collection: db.Collection("users"),
	}
}

func NewRefreshTokenRepository(db *mongo.Database) RefreshTokenRepository {
	return &refreshTokenRepository{
		db:         db,
		collection: db.Collection("refresh_tokens"),
	}
}

func NewPasswordResetRepository(db *mongo.Database) PasswordResetRepository {
	return &passwordResetRepository{
		db:         db,
		collection: db.Collection("password_resets"),
	}
}

// User Repository Implementation
func (r *userRepository) CreateUser(user *domain.User) (*domain.User, error) {
	user.ID = primitive.NewObjectID()
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()

	_, err := r.collection.InsertOne(context.Background(), user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *userRepository) GetUserByEmail(email string) (*domain.User, error) {
	var user domain.User
	err := r.collection.FindOne(context.Background(), bson.M{"email": email}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetUserByID(id primitive.ObjectID) (*domain.User, error) {
	var user domain.User
	err := r.collection.FindOne(context.Background(), bson.M{"_id": id}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetUserByProviderID(provider, providerID string) (*domain.User, error) {
	var user domain.User
	err := r.collection.FindOne(context.Background(), bson.M{
		"provider":    provider,
		"provider_id": providerID,
	}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) UpdateUser(user *domain.User) error {
	user.UpdatedAt = time.Now()
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": user.ID},
		bson.M{"$set": user},
	)
	return err
}

func (r *userRepository) DeleteUser(id primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(context.Background(), bson.M{"_id": id})
	return err
}

func (r *userRepository) AddPushToken(userID primitive.ObjectID, pushToken domain.PushToken) error {
	pushToken.CreatedAt = time.Now()
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": userID},
		bson.M{
			"$pull": bson.M{"push_tokens": bson.M{"token": pushToken.Token}},
		},
	)
	if err != nil {
		return err
	}

	_, err = r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": userID},
		bson.M{
			"$push": bson.M{"push_tokens": pushToken},
		},
	)
	return err
}

func (r *userRepository) RemovePushToken(userID primitive.ObjectID, token string) error {
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"_id": userID},
		bson.M{
			"$pull": bson.M{"push_tokens": bson.M{"token": token}},
		},
	)
	return err
}

// Refresh Token Repository Implementation
func (r *refreshTokenRepository) CreateRefreshToken(token *domain.RefreshToken) error {
	token.ID = primitive.NewObjectID()
	token.CreatedAt = time.Now()
	_, err := r.collection.InsertOne(context.Background(), token)
	return err
}

func (r *refreshTokenRepository) GetRefreshToken(token string) (*domain.RefreshToken, error) {
	var refreshToken domain.RefreshToken
	err := r.collection.FindOne(context.Background(), bson.M{"token": token}).Decode(&refreshToken)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("refresh token not found")
		}
		return nil, err
	}
	return &refreshToken, nil
}

func (r *refreshTokenRepository) DeleteRefreshToken(token string) error {
	_, err := r.collection.DeleteOne(context.Background(), bson.M{"token": token})
	return err
}

func (r *refreshTokenRepository) DeleteUserRefreshTokens(userID primitive.ObjectID) error {
	_, err := r.collection.DeleteMany(context.Background(), bson.M{"user_id": userID})
	return err
}

// Password Reset Repository Implementation
func (r *passwordResetRepository) CreatePasswordReset(reset *domain.PasswordReset) error {
	reset.ID = primitive.NewObjectID()
	reset.CreatedAt = time.Now()
	_, err := r.collection.InsertOne(context.Background(), reset)
	return err
}

func (r *passwordResetRepository) GetPasswordReset(token string) (*domain.PasswordReset, error) {
	var reset domain.PasswordReset
	err := r.collection.FindOne(context.Background(), bson.M{
		"token":      token,
		"used":       false,
		"expires_at": bson.M{"$gt": time.Now()},
	}).Decode(&reset)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("password reset token not found or expired")
		}
		return nil, err
	}
	return &reset, nil
}

func (r *passwordResetRepository) MarkPasswordResetUsed(token string) error {
	_, err := r.collection.UpdateOne(
		context.Background(),
		bson.M{"token": token},
		bson.M{"$set": bson.M{"used": true}},
	)
	return err
}

func (r *passwordResetRepository) DeleteExpiredResets() error {
	_, err := r.collection.DeleteMany(context.Background(), bson.M{
		"expires_at": bson.M{"$lt": time.Now()},
	})
	return err
}
