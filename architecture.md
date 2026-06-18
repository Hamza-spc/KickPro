# KickPro – Project Architecture

## 🧭 Project Overview
KickPro is a football talent discovery and development platform connecting players with scouts through verified skills, drills, match participation, and AI-powered search and coaching.

---

## 🏗️ Services & Ports

| Service         | Tech                    | Port  | Role                            |
|----------------|-------------------------|-------|---------------------------------|
| Backend API     | Spring Boot 3 + Java 21 | 8080  | Core business logic + REST API  |
| Mobile App      | Flutter 3 + Dart        | –     | Cross-platform mobile client    |
| AI Service      | Python 3.11 + FastAPI   | 8000  | AI features microservice        |
| Database        | PostgreSQL 15           | 5432  | Relational data storage         |
| Message Broker  | Apache Kafka            | 9092  | Async event streaming           |
| Cache           | Redis                   | 6379  | Session cache + rate limiting   |
| Media Storage   | Cloudinary              | –     | Videos + profile photos         |

---

## ☁️ Infrastructure & DevOps

### Local Development
- Docker + Docker Compose runs all services locally with one command
- Every service has its own Dockerfile
- docker-compose.yml orchestrates: Spring Boot + PostgreSQL + Kafka + Zookeeper + Redis + Python AI service

### Cloud (AWS) — Deferred
AWS deployment is deferred until the project has real users.
Docker + CI/CD files are written in Phase 0 but not deployed yet.
When ready to deploy:
| AWS Service | Purpose |
|-------------|---------|
| EC2 | Host Spring Boot backend + Python AI service |
| RDS | Managed PostgreSQL database |
| ECR | Store Docker images |

### CI/CD (GitHub Actions)
- Trigger: every push to main branch
- Pipeline: Run tests → Build Docker image (no deployment yet)
```
.github/
└── workflows/
    ├── backend-ci.yml     # build + test only
    └── ai-service-ci.yml  # build + test only
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
| `challenge.winner.announced` | Backend | Notification Service | Weekly challenge winner picked |

---

## 👥 User Roles
- **Player** — creates profile, uploads videos, completes drills, joins matches, earns certifications, gets AI coaching
- **Scout** — browses/filters players, views drill results, bookmarks players, uses AI assistant
- **Admin** — validates drills, manages courses, posts announcements
- **Agent** — verified talent agent, posts official trials, messages players directly

---

## 🗃️ Core Entities

```
User
├── id, email, password (hashed), role (PLAYER | SCOUT | ADMIN | AGENT)
├── createdAt, updatedAt

PlayerProfile
├── id, userId (FK), fullName, dateOfBirth, city, position
├── preferredFoot, bio, profilePhotoUrl (Cloudinary URL)
├── height (cm), weight (kg)
├── credibilityScore (computed)

Skills (star ratings 1–10, set by player via slider)
├── id, playerId (FK)
├── dribbling (1–10), shooting (1–10), passing (1–10)
├── speed (1–10), heading (1–10), stamina (1–10)
│
│ Computed automatically from ratings:
├── strengths → skills rated 7–10
└── weaknesses → skills rated 1–4

Video
├── id, playerId (FK), title, cloudinaryUrl, skillTag
├── viewsCount, averageRating, uploadedAt

Drill (tree data structure — parentDrillId + position define progression order)
├── id, title, description, rules, level (BEGINNER | INTERMEDIATE | ADVANCED)
├── position (order in progression), parentDrillId (FK, nullable)
├── targetSkill (dribbling | shooting | passing | speed | heading | stamina)

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
├── id, authorId (FK), title, content, type (TRIAL | NEWS | TOURNAMENT | OFFICIAL_TRIAL)
├── createdAt

ScoutFeedback
├── id, scoutId (FK), playerId (FK)
├── note (private), technicalRating (1–5), potentialRating (1–5)
├── createdAt

WeeklyChallenge
├── id, title, description, skillTag
├── startDate, endDate, status (ACTIVE | CLOSED | JUDGED)
├── winnerId (FK, nullable)

ChallengeSubmission
├── id, challengeId (FK), playerId (FK)
├── videoCloudinaryUrl, votes (int)
├── submittedAt

InjuryRecord
├── id, playerId (FK)
├── injuryType (MUSCLE | JOINT | BONE | OTHER)
├── bodyPart (knee, hamstring, ankle, etc.)
├── severity (MILD | MODERATE | SEVERE)
├── injuredAt, expectedRecovery
├── status (ACTIVE | RECOVERED)

AgentProfile
├── id, userId (FK), agencyName, licenseNumber
├── verifiedByAdmin (boolean)
├── specialization (YOUTH | SENIOR | INTERNATIONAL)
```

---

## 🔐 Auth Flow
- Registration → role selection (PLAYER / SCOUT / AGENT) → JWT issued by Spring Boot
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
| POST /recommend-drills | Player skill ratings (1–10) + weaknesses | Suggested drill path targeting weak skills |
| POST /meal-plan | age, height(cm), weight(kg), position | Football-specific daily meal plan |
| POST /recovery-plan | injuryType, bodyPart, severity, playerProfile | Recovery nutrition + rehabilitation exercises |

### Meal Plan Rules (CRITICAL for AI prompt):
- Football players ONLY — NOT bodybuilders, NOT runners
- Account for: match days vs training days vs rest days
- Include: pre-match meal, post-match recovery, daily macros
- Position-specific: striker vs defender vs goalkeeper vs midfielder
- Age-specific: under 18 needs different guidance than adults

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
├── assets/
│   ├── appicon_logo.png
│   └── fullwordmark_logo.png
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
│   │   ├── api_client.dart
│   │   └── endpoints.dart
│   ├── auth/
│   └── theme/
├── features/
│   ├── auth/
│   ├── profile/
│   ├── drills/
│   ├── videos/
│   ├── matches/
│   ├── courses/
│   ├── search/
│   ├── ai_coach/
│   ├── challenges/
│   ├── leaderboard/
│   └── agents/
└── shared/
    ├── widgets/
    └── models/
```

### Python AI Service
```
ai-service/app/
├── main.py
├── routers/
│   ├── scout_assist.py
│   ├── video_feedback.py
│   ├── course_generator.py
│   ├── score_explainer.py
│   ├── drill_recommender.py
│   ├── meal_plan.py
│   └── recovery_plan.py
├── services/
│   └── llm.py
└── models/
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
- Feature-first: features/<name>/screens|widgets|models|providers
- All models have fromJson + toJson
- Riverpod for ALL state — setState only for local UI state
- JWT in flutter_secure_storage — never SharedPreferences
- Always handle loading + error + empty states
- go_router for ALL navigation — never Navigator.push directly
- Never hardcode colors or font sizes — always use theme
- UI must be clean, modern, interactive — no generic AI-looking screens
- Build order per phase: backend first → test with Postman → then Flutter
- Drill UI: progression list in Phase 2 (see Drill UI Strategy below) — full visual tree deferred to Phase 6

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
- Use OpenAI — always Gemini
- Change anything not explicitly asked for
- Add unrequested features or refactors
- Move to next phase without verifying current phase works
- Build Flutter before backend is tested with Postman
- Build Duolingo-style drill tree UI before Phase 6 — use progression list in Phase 2 instead

---

## 🎯 Drill UI Strategy (Option C)

The backend always uses a **tree data structure** (`parentDrillId`, `position`, level). Progression logic, locking, badges, and admin validation are unchanged.

**Phase 2–5 — Progression list (build now):**
```
[✅] Juggling 20 touches          — completed
[✅] Cone dribbling               — completed
[🔵] Shooting zones               — current (active)
[🔒] Advanced combo               — locked
[🔒] Speed drill                  — locked
```
- Styled vertical list with status icons per drill
- Level selector pills: Beginner / Intermediate / Advanced
- Same API, same progression rules — list is a view layer only

**Phase 6 — Visual tree upgrade (build last):**
- Replace list with Duolingo-style node tree (connectors, glow, locked/active/completed nodes)
- No backend changes — UI-only upgrade using existing drill endpoints

---

## 🚀 Build Phases

### Phase 0 — DevOps Foundation
- Dockerfile for Spring Boot
- Dockerfile for Python AI service
- docker-compose.yml (Spring Boot + PostgreSQL + Kafka + Zookeeper + Redis)
- GitHub Actions CI/CD (build + test only — NO deployment to AWS yet)
- .env + .env.example

### Phase 1 — Authentication + Profiles
Backend first:
- User entity + Role enum (PLAYER | SCOUT | ADMIN | AGENT)
- JWT auth filter + Security config
- Register + Login endpoints
- PlayerProfile + Skills entities (1–10 star ratings)
- Profile API endpoints
- Cloudinary profile photo upload

Flutter after Postman testing:
- Auth screens (login + register)
- Profile setup screen (star rating sliders)
- Player profile screen

### Phase 2 — Video + Drill System
Backend first:
- Video entity + Cloudinary upload API
- Drill tree entity + DrillSubmission (tree data structure — parentDrillId, position)
- Manual validation flow (admin)
- Kafka: drill.submitted + video.uploaded events
- Badges system

Flutter after Postman testing:
- Video feed screen
- Drill progression list (styled list with ✅ / 🔵 / 🔒 — see Drill UI Strategy)
- Drill submission screen

### Phase 3 — Match Booking + Chat
Backend first:
- Stadium + Match + MatchParticipant entities
- Booking API with @Transactional double-booking prevention
- WebSocket chatroom per match
- Post-match rating system
- Kafka: match.booked + match.completed events

Flutter after Postman testing:
- Match booking screen
- Chatroom screen
- Post-match rating screen

### Phase 4 — Certifications + Search + Credibility
Backend first:
- Course + Lesson + Quiz + Certification entities
- Credibility score computation
- Advanced player search with filters + pagination

Flutter after Postman testing:
- Course screen + quiz
- Scout search screen
- Credibility score display

### Phase 5 — AI Features
Backend + Python first:
- Python Gemini integration for all 7 endpoints
- Meal plan (football-specific nutrition)
- Recovery plan (injury-specific)
- Drill recommender (based on weak skill ratings)
- AI Scout Assistant
- Video feedback
- Score explainer
- Course generator

Flutter after testing:
- AI Coach screen (meal plan + drill recommendations + recovery plan)
- AI scout assistant screen

### Phase 6 — Additional Features
Backend first:
- Player comparison endpoint
- Match history timeline endpoint
- Scout feedback entity + endpoints
- Weekly challenges entities + endpoints + Kafka event
- Position-specific leaderboard endpoint
- Injury tracker entity + endpoints
- Agent profile entity + endpoints

Flutter after Postman testing:
- Player comparison screen
- Match history timeline screen
- Scout feedback screen
- Weekly challenges screen
- Leaderboard screen
- Injury tracker screen
- Agent profile + trial announcements screen
- Drill tree UI upgrade (last — replace progression list with Duolingo-style visual tree; UI only)

---

## 🔑 Required Keys/Tokens (always ask before using)
- CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET → Phase 1
- JWT_SECRET (openssl rand -hex 32) → Phase 1
- GEMINI_API_KEY (aistudio.google.com — free) → Phase 5
- AWS keys → Deferred (no deployment planned yet)
