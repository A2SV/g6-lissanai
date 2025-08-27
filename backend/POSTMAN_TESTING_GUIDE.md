# LissanAI API - Postman Testing Guide

## 📧 Email Configuration (Optional)

Before testing password reset functionality, you can configure email sending:

1. **Copy environment template**:
   ```bash
   cp .env.example .env
   ```

2. **Configure SMTP settings** in `.env`:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-app-password
   FROM_EMAIL=your-email@gmail.com
   FRONTEND_URL=http://localhost:3000
   ```

3. **Test email functionality**:
   ```bash
   go run test_email.go
   ```

**Note**: If SMTP is not configured, password reset links will be printed to console instead.

## Server Information
- **Base URL**: `http://localhost:8080`
- **API Base Path**: `/api/v1`
- **Swagger Documentation**: `http://localhost:8080/swagger/index.html`

## Testing Endpoints with Postman

### 1. User Registration
**Endpoint**: `POST /api/v1/auth/register`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Expected Response** (201 Created):
```json
{
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900
}
```

---

### 2. User Login
**Endpoint**: `POST /api/v1/auth/login`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Expected Response** (200 OK):
```json
{
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900
}
```

**⚠️ Important**: Save the `access_token` from the response - you'll need it for protected endpoints!

---

### 3. Get User Profile (Protected)
**Endpoint**: `GET /api/v1/users/me`

**Headers**:
```
Authorization: Bearer YOUR_ACCESS_TOKEN_HERE
```

**Expected Response** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439011",
  "name": "John Doe",
  "email": "john@example.com",
  "settings": {},
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

### 4. Update User Profile (Protected)
**Endpoint**: `PATCH /api/v1/users/me`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer YOUR_ACCESS_TOKEN_HERE
```

**Body** (raw JSON):
```json
{
  "name": "John Updated",
  "settings": {
    "language": "en",
    "notifications": true,
    "theme": "dark"
  }
}
```

**Expected Response** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439011",
  "name": "John Updated",
  "email": "john@example.com",
  "settings": {
    "language": "en",
    "notifications": true,
    "theme": "dark"
  },
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

### 5. Social Authentication
**Endpoint**: `POST /api/v1/auth/social`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "provider": "google",
  "access_token": "ya29.a0AfH6SMC...",
  "name": "Jane Smith",
  "email": "jane@gmail.com"
}
```

**Expected Response** (200 OK):
```json
{
  "user": {
    "id": "507f1f77bcf86cd799439012",
    "name": "Jane Smith",
    "email": "jane@gmail.com",
    "provider": "google",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900
}
```

---

### 6. Refresh Token
**Endpoint**: `POST /api/v1/auth/refresh`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "refresh_token": "YOUR_REFRESH_TOKEN_HERE"
}
```

**Expected Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900
}
```

---

### 7. Forgot Password
**Endpoint**: `POST /api/v1/auth/forgot-password`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "email": "john@example.com"
}
```

**Expected Response** (200 OK):
```json
{
  "message": "Password reset link sent to your email"
}
```

---

### 8. Reset Password
**Endpoint**: `POST /api/v1/auth/reset-password`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "token": "reset_token_from_email",
  "new_password": "newpassword123"
}
```

**Expected Response** (200 OK):
```json
{
  "message": "Password reset successfully"
}
```

---

### 9. Add Push Token (Protected) ✅ TESTED
**Endpoint**: `POST /api/v1/users/me/push-token`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer YOUR_ACCESS_TOKEN_HERE
```

**Body** (raw JSON):
```json
{
  "token": "fcm_token_123456789",
  "platform": "ios"
}
```

**Expected Response** (200 OK):
```json
{
  "message": "Push token registered successfully"
}
```

**Note**: This endpoint allows users to register device tokens for push notifications. Supports both FCM (Android) and APNs (iOS) tokens. The platform field should be either "ios" or "android".

---

### 10. Logout (Protected)
**Endpoint**: `POST /api/v1/auth/logout`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer YOUR_ACCESS_TOKEN_HERE
```

**Body** (raw JSON - optional):
```json
{
  "refresh_token": "YOUR_REFRESH_TOKEN_HERE"
}
```

**Expected Response** (200 OK):
```json
{
  "message": "Successfully logged out"
}
```

---

### 11. Delete Account (Protected)
**Endpoint**: `DELETE /api/v1/users/me`

**Headers**:
```
Authorization: Bearer YOUR_ACCESS_TOKEN_HERE
```

**Expected Response** (200 OK):
```json
{
  "message": "Account deleted successfully"
}
```

---

## Testing Flow Recommendation

### Basic Flow:
1. **Register** a new user → Save the `access_token` and `refresh_token`
2. **Get Profile** using the access token
3. **Update Profile** with new information
4. **Add Push Token** for notifications
5. **Logout** to invalidate tokens

### Authentication Flow:
1. **Register** a user
2. **Login** with the same credentials
3. Wait 15+ minutes for token to expire
4. **Refresh Token** to get a new access token
5. **Forgot Password** to test password reset
6. **Reset Password** with a valid token (you'll need to check your database for the token)

### Error Testing:
- Try accessing protected endpoints without Authorization header
- Try with invalid/expired tokens
- Try registering with the same email twice
- Try login with wrong credentials

## Common Error Responses

**400 Bad Request**:
```json
{
  "error": "validation error message"
}
```

**401 Unauthorized**:
```json
{
  "error": "invalid or expired token"
}
```

**409 Conflict** (duplicate email):
```json
{
  "error": "user with this email already exists"
}
```

**500 Internal Server Error**:
```json
{
  "error": "internal server error message"
}
```

## Tips for Postman Testing

1. **Create Environment Variables**:
   - `base_url`: `http://localhost:8080`
   - `access_token`: (set this after login/register)
   - `refresh_token`: (set this after login/register)

2. **Use Pre-request Scripts** to automatically set tokens:
   ```javascript
   // In login/register request's Tests tab:
   if (pm.response.code === 200 || pm.response.code === 201) {
       const response = pm.response.json();
       pm.environment.set("access_token", response.access_token);
       pm.environment.set("refresh_token", response.refresh_token);
   }
   ```

3. **Use Variables in Headers**:
   ```
   Authorization: Bearer {{access_token}}
   ```

4. **Create a Collection** and organize requests by feature (Auth, Users, etc.)

Happy testing! 🚀