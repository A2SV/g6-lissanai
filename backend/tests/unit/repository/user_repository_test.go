package repository_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/integration/mtest"
	"lissanai.com/backend/internal/domain"
	repo "lissanai.com/backend/internal/repository"
)

func TestUserRepository_CreateUser(t *testing.T) {
	mt := mtest.New(t, mtest.NewOptions().ClientType(mtest.Mock))

	mt.Run("successful user creation", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		user := &domain.User{
			Name:         "Test User",
			Email:        "test@example.com",
			PasswordHash: "hashed_password",
		}

		// Mock successful insert
		mt.AddMockResponses(mtest.CreateSuccessResponse())

		// Test
		result, err := userRepo.CreateUser(user)

		// Assertions
		require.NoError(t, err)
		assert.NotNil(t, result)
		assert.NotEmpty(t, result.ID)
		assert.Equal(t, "Test User", result.Name)
		assert.Equal(t, "test@example.com", result.Email)
	})

	mt.Run("duplicate email error", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		user := &domain.User{
			Name:         "Test User",
			Email:        "test@example.com",
			PasswordHash: "hashed_password",
		}

		// Mock duplicate key error
		mt.AddMockResponses(mtest.CreateWriteErrorsResponse(mtest.WriteError{
			Code:    11000, // Duplicate key error
			Message: "duplicate key error",
		}))

		// Test
		result, err := userRepo.CreateUser(user)

		// Assertions
		assert.Error(t, err)
		assert.Nil(t, result)
	})
}

func TestUserRepository_GetUserByEmail(t *testing.T) {
	mt := mtest.New(t, mtest.NewOptions().ClientType(mtest.Mock))

	mt.Run("user found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()
		expectedUser := domain.User{
			ID:    userID,
			Name:  "Test User",
			Email: "test@example.com",
		}

		// Mock successful find
		mt.AddMockResponses(mtest.CreateCursorResponse(1, "foo.bar", mtest.FirstBatch, bson.D{
			{"_id", userID},
			{"name", "Test User"},
			{"email", "test@example.com"},
		}))

		// Test
		result, err := userRepo.GetUserByEmail("test@example.com")

		// Assertions
		require.NoError(t, err)
		assert.NotNil(t, result)
		assert.Equal(t, expectedUser.ID, result.ID)
		assert.Equal(t, expectedUser.Name, result.Name)
		assert.Equal(t, expectedUser.Email, result.Email)
	})

	mt.Run("user not found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)

		// Mock no documents found
		mt.AddMockResponses(mtest.CreateCursorResponse(0, "foo.bar", mtest.FirstBatch))

		// Test
		result, err := userRepo.GetUserByEmail("nonexistent@example.com")

		// Assertions
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "user not found")
		assert.Nil(t, result)
	})
}

func TestUserRepository_GetUserByID(t *testing.T) {
	mt := mtest.New(t, mtest.NewOptions().ClientType(mtest.Mock))

	mt.Run("user found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()
		expectedUser := domain.User{
			ID:    userID,
			Name:  "Test User",
			Email: "test@example.com",
		}

		// Mock successful find
		mt.AddMockResponses(mtest.CreateCursorResponse(1, "foo.bar", mtest.FirstBatch, bson.D{
			{"_id", userID},
			{"name", "Test User"},
			{"email", "test@example.com"},
		}))

		// Test
		result, err := userRepo.GetUserByID(userID)

		// Assertions
		require.NoError(t, err)
		assert.NotNil(t, result)
		assert.Equal(t, expectedUser.ID, result.ID)
		assert.Equal(t, expectedUser.Name, result.Name)
		assert.Equal(t, expectedUser.Email, result.Email)
	})

	mt.Run("user not found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()

		// Mock no documents found
		mt.AddMockResponses(mtest.CreateCursorResponse(0, "foo.bar", mtest.FirstBatch))

		// Test
		result, err := userRepo.GetUserByID(userID)

		// Assertions
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "user not found")
		assert.Nil(t, result)
	})
}

func TestUserRepository_UpdateUser(t *testing.T) {
	mt := mtest.New(t, mtest.NewOptions().ClientType(mtest.Mock))

	mt.Run("successful update", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()
		user := &domain.User{
			ID:   userID,
			Name: "Updated User",
			Settings: map[string]interface{}{
				"theme": "dark",
			},
		}

		// Mock successful update
		mt.AddMockResponses(mtest.CreateSuccessResponse())

		// Test
		err := userRepo.UpdateUser(user)

		// Assertions
		assert.NoError(t, err)
	})

	mt.Run("user not found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()
		user := &domain.User{ID: userID, Name: "Updated User"}

		// Mock no documents matched
		mt.AddMockResponses(mtest.CreateWriteErrorsResponse(mtest.WriteError{
			Code:    0,
			Message: "no documents matched",
		}))

		// Test
		err := userRepo.UpdateUser(user)

		// Assertions
		assert.Error(t, err)
	})
}

func TestUserRepository_DeleteUser(t *testing.T) {
	mt := mtest.New(t, mtest.NewOptions().ClientType(mtest.Mock))

	mt.Run("successful deletion", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()

		// Mock successful delete
		mt.AddMockResponses(mtest.CreateSuccessResponse())

		// Test
		err := userRepo.DeleteUser(userID)

		// Assertions
		assert.NoError(t, err)
	})

	mt.Run("user not found", func(mt *mtest.T) {
		// Setup
		userRepo := repo.NewUserRepository(mt.DB)
		userID := primitive.NewObjectID()

		// Mock no documents matched
		mt.AddMockResponses(mtest.CreateWriteErrorsResponse(mtest.WriteError{
			Code:    0,
			Message: "no documents matched",
		}))

		// Test
		err := userRepo.DeleteUser(userID)

		// Assertions
		assert.Error(t, err)
	})
}
