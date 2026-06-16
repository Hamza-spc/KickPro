# KickPro – Project Architecture

## 🧭 Project Overview
KickPro is a football talent discovery and development platform connecting players with scouts through verified skills, drills, match participation, and AI-powered search.

---

## 🏗️ Services & Ports

| Service         | Tech                  | Port  | Role                            |
|----------------|-----------------------|-------|---------------------------------|
| Backend API     | Spring Boot 3 + Java 21 | 8080  | Core business logic + REST API  |
| Mobile App      | Flutter 3 + Dart      | –     | Cross-platform mobile client    |
| AI Service      | Python 3.11 + FastAPI | 8000  | AI features microservice        |
| Database        | PostgreSQL 15         | 5432  | Relational data storage         |
| Message Broker  | Apache Kafka          | 9092  | Async event streaming           |
| Cache           | Redis                 | 6379  | Session cache + rate limiting   |
| Media Storage   | Cloudinary            | –     | Videos + profile photos         |

---

## ☁️ Infrastructure & DevOps

### Local Development
- Docker + Docker Compose runs all services locally with one command
- Every service has its own Dockerfile
- docker-compose.yml orchestrates: Spring Boot + PostgreSQL + Kafka + Zookeeper + Redis + Python AI service

### Cloud (AWS)
| AWS Service | Purpose |
|-------------|---------|
| EC2 | Host Spring Boot backend + Python AI service |
| RDS | Managed PostgreSQL database |
| ECR | Store Docker images |

### CI/CD (GitHub Actions)
- Trigger: every push to main branch
- Pipeline: Run tests → Build Docker image → Push to AWS ECR → Deploy to EC2
```
.github/
└── workflows/
    ├── backend-ci.yml
    └── ai-service-ci.yml
```

---

## 📨 Kafka Event Flows

| Event Topic | Producer | Consumer | Trigger |
|-------------|----------|----------|---------|
| `drill.submitted` | Backend | Notification + AI Service | Player submits drill video |
| `drill.validated` | Backend | Player Service | Admin approves/rejects drill |
| `match.booked` | Backend | Notification Service | Match booking confirmed |
| `match.completed` | Backend | Rating Service | Match status → COMPLETED |
| `video.uploaded` | Backend | AI Service | Player uploads a video |

---

## 👥 User Roles
- **Player** — creates profile, uploads videos, completes drills, joins matches, earns certifications
- **Scout** — browses/filters players, views drill results, bookmarks players, uses AI assistant
- **Admin** — validates drills, manages courses, posts announcements

---

## 🗃️ Core Entities

```
User
├── id, email, password (hashed), role (PLAYER | SCOUT | ADMIN)
├── createdAt, updatedAt

PlayerProfile
├── id, userId (FK), fullName, age, city, position
├── preferredFoot, bio, profilePhotoUrl (Cloudinary URL)
├── credibilityScore (computed)

Skills
├── id, playerId (FK)
├── dribbling, shooting, passing, speed, heading, stamina (0–100)

Video
├── id, playerId (FK), title, cloudinaryUrl, skillTag
├── viewsCount, averageRating, uploadedAt

Drill
├── id, title, description, rules, level (BEGINNER | INTERMEDIATE | ADVANCED)
├── position (order in tree), parentDrillId (FK, nullable)

DrillSubmission
├── id, playerId (FK), drillId (FK), videoCloudinaryUrl
├── status (PENDING | APPROVED | REJECTED), score
├── submittedAt, reviewedAt, reviewedBy (adminId FK)

Badge
├── id, playerId (FK), drillId (FK), earnedAt, badgeType

Match
├── id, stadiumId (FK), organizerId (FK), dateTime
├── maxPlayers, status (OPEN | FULL | COMPLETED | CANCELLED)

MatchParticipant
├── id, matchId (FK), playerId (FK), status (PENDING | APPROVED | REJECTED)
├── joinedAt

PlayerRating
├── id, matchId (FK), raterId (FK), ratedPlayerId (FK)
├── performanceScore, punctualityScore, teamworkScore, behaviorScore

Stadium
├── id, name, location, description, pricePerHour, photos

Course
├── id, title, description, level
├── lessons (List<Lesson>)

Lesson
├── id, courseId (FK), title, content, orderIndex

Quiz
├── id, lessonId (FK), questions (List<QuizQuestion>)

QuizQuestion
├── id, quizId (FK), question, options (JSON), correctAnswer

Certification
├── id, playerId (FK), courseId (FK), earnedAt, badgeUrl

ChatRoom
├── id, matchId (FK), createdAt

ChatMessage
├── id, roomId (FK), senderId (FK), content, sentAt

Announcement
├── id, authorId (FK), title, content, type (TRIAL | NEWS | TOURNAMENT)
├── createdAt
```

---

## 🔐 Auth Flow
- Registration → role selection (PLAYER / SCOUT) → JWT issued by Spring Boot
- JWT stored in flutter_secure_storage on Flutter client
- Every request: Authorization: Bearer <token> header
- Spring Boot validates via JwtAuthFilter on every request
- Role-based access via @PreAuthorize annotations

---

## 🌐 API Convention
- Base prefix: /api/v1/
- Standard response wrapper:
```json
{
  "success": true,
  "data": { },
  "message": "Operation successful",
  "timestamp": "2025-01-01T12:00:00"
}
```

---

## 🤖 AI Service Endpoints (Python FastAPI)

| Endpoint | Input | Output |
|----------|-------|--------|
| POST /scout-assist | NL query + player list JSON | Matched player IDs + explanation |
| POST /video-feedback | Video URL + skill tag | Structured scouting report |
| POST /generate-course | Course title + content | Lessons + quiz questions JSON |
| POST /explain-score | Player stats JSON | NL explanation of score |
| POST /recommend-drills | Player skill ratings | Suggested drill path |

---

## 📁 Folder Structure

### Project Root
```
KickPro/
├── .cursorrules
├── architecture.md
├── app_description.md
├── docker-compose.yml
├── .env
├── .env.example
├── .github/workflows/
├── backend/
├── mobile/
└── ai-service/
```

### Spring Boot
```
backend/src/main/java/com/kickpro/backend/
├── config/          # Security, JWT, Kafka, WebSocket, Cloudinary config
├── controller/      # REST controllers per module
├── service/         # Business logic (interface + impl)
├── repository/      # JPA repositories
├── entity/          # JPA entities
├── dto/             # Request/Response DTOs
├── event/           # Kafka event classes + @KafkaListener consumers
├── exception/       # GlobalExceptionHandler
└── util/            # JwtUtil, CloudinaryService, helpers
```

### Flutter
```
mobile/lib/
├── main.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart      # Dio instance + interceptors
│   │   └── endpoints.dart       # All API endpoint constants
│   ├── auth/                    # JWT storage + auth state
│   └── theme/                   # Colors, typography, design tokens
├── features/
│   ├── auth/                    # Login, register
│   ├── profile/                 # Player/Scout profiles
│   ├── drills/                  # Drill tree + submission
│   ├── videos/                  # Video feed + upload
│   ├── matches/                 # Booking + chatroom
│   ├── courses/                 # Certifications + quizzes
│   └── search/                  # Scout search + AI assistant
└── shared/
    ├── widgets/                 # Reusable UI components
    └── models/                  # Dart models matching backend DTOs
```

### Python AI Service
```
ai-service/app/
├── main.py
├── routers/         # One router per AI feature
├── services/        # LLM/Gemini logic
└── models/          # Pydantic schemas
```

---

## ⚙️ Coding Conventions

### Spring Boot
- DTOs always separate from entities
- Services always @Transactional on write operations
- ResponseEntity<ApiResponse<T>> on all endpoints
- GlobalExceptionHandler with @RestControllerAdvice
- Never expose password or sensitive fields in responses
- @Valid on all request body parameters
- One service interface + one implementation per module
- All Cloudinary operations via util/CloudinaryService.java
- Kafka producers in service layer, consumers in event/ package

### Flutter
- Dio for ALL HTTP — never http package
- Feature-first structure: features/<name>/screens|widgets|models|providers
- All models have fromJson + toJson
- Riverpod for ALL state — setState only for local UI state
- JWT in flutter_secure_storage — never SharedPreferences
- Always handle loading + error + empty states
- go_router for ALL navigation — never Navigator.push directly
- Never hardcode colors or font sizes — always use theme
- UI must be clean, modern, interactive — no generic AI-looking screens

### Python
- Pydantic BaseModel for all I/O
- All LLM calls in try/except
- Consistent response: { success, data, message }
- Use Gemini API (free) — never OpenAI

---

## 🚫 What Claude Must Never Do
- Return JPA entities from controllers — always DTOs
- Put business logic in controllers
- Forget @Transactional on write operations
- Hardcode any secret, URL, or credential
- Use http package in Flutter — always Dio
- Store JWT in SharedPreferences — always flutter_secure_storage
- Use setState for shared state — always Riverpod
- Use Navigator.push — always go_router
- Use OpenAI — always Gemini (free)
- Change anything not explicitly asked for
- Add unrequested features or refactors
- Move to next phase without verifying current phase works

---

## 🚀 Build Phases

### Phase 0 — DevOps Foundation ✅
- Dockerfile for Spring Boot
- Dockerfile for Python AI service
- docker-compose.yml
- GitHub Actions CI/CD pipelines
- .env.example

### Phase 1 — Authentication + Profiles
- User entity + Role enum
- JWT auth filter + Security config
- Register + Login endpoints
- PlayerProfile + Skills entities + APIs
- Cloudinary profile photo upload
- Flutter: auth screens + profile screens

### Phase 2 — Video + Drill System
- Video entity + Cloudinary upload API
- Drill tree entity + DrillSubmission
- Manual validation flow (admin)
- Kafka: drill.submitted + video.uploaded events
- Badges system
- Flutter: video feed + drill tree UI

### Phase 3 — Match Booking + Chat
- Stadium + Match + MatchParticipant entities
- Booking API with @Transactional double-booking prevention
- WebSocket chatroom per match
- Post-match rating system
- Kafka: match.booked + match.completed events
- Flutter: booking screen + chatroom

### Phase 4 — Certifications + Search + Credibility
- Course + Lesson + Quiz + Certification entities
- Credibility score computation
- Advanced player search with filters + pagination
- Flutter: course screen + quiz + scout search

### Phase 5 — AI Features + Deployment
- Python Gemini integration for all 5 endpoints
- Flutter: AI scout assistant screen
- AWS EC2 + RDS setup
- CI/CD pipeline goes live
- Final testing + deployment

---

## 🔑 Required Keys/Tokens (Claude must ask before using)
- CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
- JWT_SECRET (generate with: openssl rand -hex 32)
- GEMINI_API_KEY (from aistudio.google.com — free)
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY (Phase 5 only)
- EC2_HOST, EC2_SSH_PRIVATE_KEY (Phase 5 only)
- DB_HOST, KAFKA_BOOTSTRAP_SERVERS, REDIS_HOST (Phase 5 only)
