# LissanAI: AI English Communication Coach for Ethiopians

![LissanAI Banner](https://placehold.co/1200x300?text=LissanAI)

LissanAI is an AI-powered application designed to help Ethiopian users master professional English communication. It acts as a personal tutor for practicing speaking, perfecting writing, and understanding complex grammar in a supportive, contextual, and non-judgmental way.

---

## ✨ Key Features

*   **🗣️ Mock Interview Practice:** Simulate interviews and get instant AI feedback on grammar, clarity, and pronunciation.
*   **💬 Free Speaking Mode:** Practice conversational English on any topic with a responsive AI partner.
*   **✍️ AI Writing Assistant:** Draft professional emails from Amharic prompts or proofread existing English text.
*   **🇪🇹 Amharic Support:** Get key grammatical explanations in Amharic to ensure full understanding.
*   **📚 Learning Paths:** Structured courses with lessons, quizzes, and progress tracking.
*   **🔥 Streak Tracking:** Gamified learning with daily streaks and activity calendars.
*   **🎯 Pronunciation Assessment:** AI-powered pronunciation feedback and improvement suggestions.

---

## 🚀 Quick Start

### Prerequisites
- **Go 1.24+** (for backend)
- **Node.js 18+** (for web)
- **Flutter 3.0+** (for mobile)
- **MongoDB 7+** (local or Atlas)

### Clone and Setup
```bash
git clone https://github.com/A2SV/g6-lissanai.git
cd g6-lissanai
```

### Backend (Go + MongoDB)
```bash
cd backend
# Create .env file (see backend/README.md for details)
go mod download
go run cmd/api/main.go
```
- **API:** `http://localhost:8080`
- **Swagger:** `http://localhost:8080/swagger/index.html`
- **Health:** `http://localhost:8080/health`

### Web (Next.js)
```bash
cd web
npm install
npm run dev
```
- **Web App:** `http://localhost:3000`

### Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

---

## 📁 Project Structure

This repository is a monorepo containing the core components of LissanAI.

```
g6-lissanai/
├── backend/           # Go API server with MongoDB
│   ├── cmd/api/       # Application entrypoint
│   ├── internal/      # Core business logic
│   │   ├── handler/   # HTTP handlers
│   │   ├── usecase/   # Business logic
│   │   ├── service/   # Domain services
│   │   ├── repository/# Data access layer
│   │   └── client/    # External API clients
│   ├── tests/         # Comprehensive test suite
│   ├── postman/       # API collection
│   └── docs/          # Swagger documentation
├── web/               # Next.js web application
│   ├── src/app/       # App router pages
│   ├── src/components/# React components
│   └── src/lib/       # Utilities and configurations
├── mobile/            # Flutter mobile app
│   ├── lib/features/  # Feature-based architecture
│   ├── lib/core/      # Core utilities
│   └── android/ios/   # Platform-specific code
└── README.md
```

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | Go (Gin), MongoDB, JWT | API server, authentication, data persistence |
| **Web** | Next.js, TypeScript, Tailwind CSS | Web interface, responsive design |
| **Mobile** | Flutter, Dart | Cross-platform mobile app |
| **AI Services** | Google Gemini, Groq, Whisper, Unreal Speech | Grammar checking, speech-to-text, text-to-speech |
| **Authentication** | JWT, Google OAuth | Secure user authentication |
| **Testing** | Go testing, testify | Unit, integration, and E2E tests |

---

## 🔧 Development

### Backend Development
- **Testing:** `go test ./...` (unit + integration + e2e)
- **Coverage:** `go test -cover ./...`
- **API Docs:** Swagger UI at `/swagger/index.html`
- **Postman:** Import `backend/postman/LissanAI_Backend.postman_collection.json`

### Web Development
- **Dev Server:** `npm run dev`
- **Build:** `npm run build`
- **Lint:** `npm run lint`

### Mobile Development
- **Run:** `flutter run`
- **Build:** `flutter build apk` (Android) / `flutter build ios` (iOS)
- **Test:** `flutter test`

---

## 📚 Documentation

- **Backend API:** [Backend README](backend/README.md) | [Swagger UI](http://localhost:8080/swagger/index.html)
- **Web App:** [Web README](web/README.md)
- **Mobile App:** [Mobile README](mobile/README.md)
- **Postman Collection:** [Backend API Collection](backend/postman/LissanAI_Backend.postman_collection.json)

---

## 🌐 Deployment

### Backend
- **Production:** Deployed on Render with MongoDB Atlas
- **Health Check:** `https://lissan-ai-backend-dev.onrender.com/health`
- **API Docs:** `https://lissan-ai-backend-dev.onrender.com/swagger/index.html`

### Web
- **Production:** Deployed on Vercel/Render
- **URL:** `https://lissanai.onrender.com`

### Mobile
- **Android:** Google Play Store (planned)
- **iOS:** App Store (planned)

---

## 🧪 Testing

The backend includes comprehensive testing:
- **Unit Tests:** Service and usecase layer testing
- **Integration Tests:** Handler and database integration
- **E2E Tests:** Complete user flow testing
- **Mocking:** External service mocking for isolated testing

Run tests:
```bash
cd backend
go test ./...                    # All tests
go test ./tests/unit/...         # Unit tests only
INTEGRATION_TESTS=true go test ./tests/integration/...  # Integration tests
E2E_TESTS=true go test ./tests/e2e/...                  # E2E tests
```

---

### 🤝 Contributing

Contributions are welcome! Please fork the repository, create a new branch for your feature, and submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

### 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
