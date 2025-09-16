## LissanAI Backend

AI-powered English coach backend built with Go (Gin) and MongoDB. It provides authentication, grammar checking, interview practice, pronunciation assessment, learning paths, streak tracking, and real-time voice conversation APIs, documented via Swagger.

### Live Deployment
- Base URL (production/dev): [lissan-ai-backend-dev.onrender.com](https://lissan-ai-backend-dev.onrender.com)
- Swagger UI (online): [Swagger Docs](https://lissan-ai-backend-dev.onrender.com/swagger/index.html)

### Tech Stack
- Go 1.24, Gin, Swaggo
- MongoDB (local or Atlas)
- JWT auth (access/refresh)
- Docker and docker-compose

### Project Structure
```
backend/
  cmd/api/main.go               # Entrypoint
  internal/
    server/                     # HTTP router and route setup
    handler/                    # HTTP handlers (controllers)
    usecase/                    # Application/business logic
    service/                    # Domain services (JWT, AI, email, streak)
    repository/                 # MongoDB repositories
    database/mongodb.go         # Mongo connection
    middleware/auth_middleware.go
    client/                     # External API clients (Groq, Whisper, TTS)
  docs/swagger.yaml             # OpenAPI spec (served at /swagger)
  Dockerfile, docker-compose.yml
  scripts/seed_learning_data.go
```

### Prerequisites
- Go 1.24+
- MongoDB 7+ (local) or MongoDB Atlas
- Make sure ports 8080 (API) and 27017 (Mongo) are available

### Quick Start (Local)
1) Clone and enter backend directory
```
cd backend
```
2) Create `.env` (see Environment Variables below), ensure MongoDB is available
3) Install dependencies and run
```
go mod download
go run cmd/api/main.go
```
4) Open Swagger: `http://localhost:8080/swagger/index.html`
5) Health: `GET http://localhost:8080/health`

### Running Tests
- All tests (unit + integration + e2e):
```
go test ./...
```
- Unit tests only (service/usecase focus):
```
go test ./tests/unit/...
```
- Integration tests (handlers + DB, requires MongoDB):
```
INTEGRATION_TESTS=true go test ./tests/integration/...
```
- End-to-end (auth/user flows through HTTP with middleware):
```
E2E_TESTS=true go test ./tests/e2e/...
```
- Coverage:
```
go test -cover ./...
```

### Environment Variables
Required for various features. Create a `.env` in `backend/` or set in your environment.

- Core
  - `PORT` default: `8080`
  - `MONGODB_URI` default: `mongodb://localhost:27017`
  - `MONGODB_DATABASE` default: `lissanai`
  - `JWT_SECRET` default: development fallback (set a strong value in prod)

- AI Services
  - `GEMINI_API_KEY` required for grammar, email drafting, pronunciation
  - `GROQ_API_KEY` required for real-time speaking
  - `HF_API_KEY` required for Whisper speech-to-text
  - `UNREAL_SPEECH_API_KEY` required for TTS in speaking
  - `UNREAL_SPEECH_VOICE_ID` required voice id for TTS

- Email (optional in dev; logs to console if unset)
  - `SMTP_HOST` default: `smtp.gmail.com`
  - `SMTP_PORT` default: `587`
  - `SMTP_USERNAME`
  - `SMTP_PASSWORD`
  - `FROM_EMAIL` default: `SMTP_USERNAME`
  - `FRONTEND_URL` default: `https://lissanai.onrender.com`

Example `.env`:
```
PORT=8080
MONGODB_URI=mongodb://localhost:27017
MONGODB_DATABASE=lissanai
JWT_SECRET=replace-with-strong-secret

GEMINI_API_KEY=your_gemini_key
GROQ_API_KEY=your_groq_key
HF_API_KEY=your_hf_key
UNREAL_SPEECH_API_KEY=your_unreal_key
UNREAL_SPEECH_VOICE_ID=your_voice_id

SMTP_USERNAME=your@email.com
SMTP_PASSWORD=app-password
FRONTEND_URL=http://localhost:3000
```

### Authentication Model
- Access tokens are JWTs signed with `JWT_SECRET`. Send on protected routes:
```
Authorization: Bearer <access_token>
```
- Refresh token is an opaque string stored in MongoDB. Exchange via:
```
POST /api/v1/auth/refresh
{
  "refresh_token": "..."
}
```
- Social auth: the web app exchanges Google OAuth with backend via:
```
POST /api/v1/auth/social
{
  "provider": "google",
  "access_token": "<provider access token>",
  "name": "<optional>",
  "email": "<optional>"
}
```

### API Overview
- Base path: `/api/v1`
- Swagger UI: `/swagger/index.html`
- Auth: Bearer tokens in `Authorization: Bearer <access_token>`

Key route groups:
- Auth: `/api/v1/auth`
  - `POST /register`, `POST /login`, `POST /social`, `POST /refresh`, `POST /forgot-password`, `POST /reset-password`, `POST /logout` (protected)
- Users: `/api/v1/users` (protected)
  - `GET /me`, `PATCH /me`, `DELETE /me`, `POST /me/push-token`
- Grammar: `/api/v1/grammar/check` (protected)
- Interview: `/api/v1/interview` (protected)
  - `POST /start`, `GET /question`, `POST /answer`, `POST /:session_id/end`
- Email drafting: `/api/v1/email`
  - `POST /generate`, `POST /edit`
- Pronunciation: `/api/v1/pronunciation`
  - `GET /sentence`, `POST /assess`
- Learning: `/api/v1/learning` (protected)
  - `GET /paths`, `POST /paths/:id/enroll`, `GET /paths/:id/progress`, `GET /lessons/:id`, `POST /lessons/:id/complete`, `POST /quizzes/:id/submit`
- Streak: `/api/v1/streak` (protected)
  - `GET /info`, `POST /freeze`, `POST /activity`, `GET /calendar`
- Realtime speaking: `GET /api/v1/ws/conversation` (WebSocket)

### Postman Collection
- A Postman collection file is provided under `backend/postman/LissanAI_Backend.postman_collection.json` with folders for Auth, Users, Grammar, Interview, Email, Pronunciation, Learning, Streak.
- Variables provided:
  - `baseUrl` (default `http://localhost:8080/api/v1`)
  - `accessToken` (set after login)
- Usage:
  1. Import the collection into Postman.
  2. Set the `baseUrl` variable in the collection or Postman environment.
  3. Run `Auth > Register` or `Auth > Login` to obtain tokens.
  4. Click `Set Access Token` (pre-request script) or manually set `accessToken`.
  5. Call protected routes; they include `Authorization: Bearer {{accessToken}}` automatically.

### Docker
Using docker-compose (runs MongoDB and API):
```
cd backend
docker compose up --build
```
API: `http://localhost:8080`

The compose file sets:
- `MONGODB_URI=mongodb://admin:password@mongodb:27017/lissanai?authSource=admin`
- `JWT_SECRET=your-super-secret-jwt-key-change-this-in-production`

Set additional envs via an `.env` file or by editing `docker-compose.yml` if you need AI/email features.

### Data and Services
- MongoDB connection configured in `internal/database/mongodb.go`
- Repositories in `internal/repository/` implement persistence
- Business logic in `internal/usecase/`
- Services in `internal/service/`: JWT, password hashing, email, grammar/AI, speaking, streak
- External clients in `internal/client/`: Groq, Whisper, Unreal TTS

### Seeding (optional)
```
go run scripts/seed_learning_data.go
```

### Deployment Notes
- Set strong `JWT_SECRET` and all AI/email envs
- Restrict CORS in `internal/server/server.go` from `*` to your frontend origin
- Use a managed MongoDB (Atlas) with IP allowlist and credentials
- Serve behind HTTPS and a reverse proxy; enable logs/metrics/health checks

### Troubleshooting
- 401 errors: ensure `Authorization: Bearer <token>` header is set and not expired; verify `JWT_SECRET` matches the server’s
- 500 on AI routes: verify `GEMINI_API_KEY`/`GROQ_API_KEY`/`HF_API_KEY`/`UNREAL_SPEECH_*` are set
- Mongo connection issues: check `MONGODB_URI`, network, and credentials; ensure DB is reachable
- Swagger not loading: confirm server started and visit `/swagger/index.html`

### Contributing
- Conventional commits preferred
- Add tests for new features (`backend/tests/...`)
- Ensure `go test ./...` passes before PR

### License
MIT (see root LICENSE)