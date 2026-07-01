# KickPro — Technical interview guide

Use this for **15-minute project pitches**, EMSI / internship defenses, and backend/mobile interviews.  
Numbers are **verified from the repo** — do not inflate.

---

## Elevator pitch (30 seconds)

> KickPro is a Morocco-first football talent platform: players build a verified digital CV (drills, matches, credibility score); scouts search and compare players with AI-assisted discovery. I built the **Flutter app**, **Spring Boot API** (127 endpoints), deployed on **AWS** with **RDS + Docker**, **CI/CD** on GitHub Actions, **Kafka** for match events, and **Gemini** for AI features.

---

## Live links

| Resource | URL |
|----------|-----|
| Marketing site | https://kick-pro.vercel.app/ |
| API | http://15.188.100.148:8080 |
| Health | http://15.188.100.148:8080/actuator/health |
| GitHub | https://github.com/Hamza-spc/KickPro |

**Mobile against prod:**

```bash
flutter run --dart-define=API_BASE_URL=http://15.188.100.148:8080
```

---

## Verified metrics

| Metric | Value |
|--------|------:|
| REST endpoints | 127 |
| JUnit tests | 32 |
| JPA repositories | 35 |
| Flutter screens | 46 |
| Docker services (local) | 6 (Postgres, Redis, Kafka, Zookeeper, backend, ai-service) |

**Honest caveats:**

- **Redis:** in Docker Compose; configured in Spring, not heavily used in business logic yet.
- **Kafka:** 4 topics; **1 consumer** (`match.booked` → notification). Producer-only for other topics.
- **SonarCloud:** wired in CI; runs when `SONAR_TOKEN` secret is set.

---

## Architecture (2 minutes)

```
Flutter (Riverpod, Dio)
    → HTTPS/HTTP → Spring Boot API (JWT, RBAC)
        → PostgreSQL (RDS on AWS)
        → Redis, Kafka (EC2 Docker)
        → Cloudinary (media)
        → Gemini via Spring AI + Python ai-service (video feedback)
```

- **Monolith API** — not microservices; one deployable JAR.
- **Event-driven slice:** `createMatch` → Kafka `match.booked` → `MatchBookedEventConsumer` → in-app notification.
- **Real-time:** WebSocket/STOMP for match chat.

Diagrams: `docs/diagrams/` (use case, sequence, class, architecture).

---

## Common questions & answers

### Why Spring Boot?

Mature ecosystem for REST, JPA, Security, Kafka, WebSocket. Good fit for a large domain (matches, drills, courses, scouts, admin) in one codebase.

### How does authentication work?

**JWT**, not Keycloak. Login returns a Bearer token; `JwtAuthFilter` validates on each request. Roles: `PLAYER`, `SCOUT`, `AGENT`, `ADMIN`.  
See [ADR 001](adr/001-jwt-authentication.md).

### How do you prevent double booking?

**Pessimistic write lock** on the `Stadium` row during `createMatch`, then overlap query on ±90 minutes.  
See [ADR 003](adr/003-pessimistic-match-booking.md).

### How is Kafka used?

**Producer:** `KafkaEventPublisher` on match booked/completed, drill submitted, video uploaded.  
**Consumer:** `MatchBookedEventConsumer` on `match.booked`.  
If Kafka is down, producer logs and skips — API still works.  
See [ADR 002](adr/002-kafka-events.md).

### What is the credibility score?

Composite score from drill approvals, quiz/certifications, match ratings, profile completeness. `CredibilityServiceImpl` recalculates after relevant events. Quiz pass threshold: **70%**.

### How does AI work?

- **Spring AI + Gemini:** scout assist, meal plans, drill recommendations, course generation, score explanation.
- **Python `ai-service`:** video feedback (separate container).
- API keys via `GEMINI_API_KEY` — never committed.

### How do you deploy?

**Path A (free tier):** EC2 `t3.micro` + RDS Postgres + Elastic IP. `docker-compose.aws.yml` runs Kafka/Redis/backend (no local Postgres).  
**CI/CD:** push to `main` → tests → SSH deploy → `/actuator/health` smoke test.

### What would you improve next?

1. HTTPS + custom domain (`api.kickpro.app`)  
2. More Kafka consumers (e.g. `match.completed`)  
3. Redis caching for feed/leaderboard  
4. Expand test coverage on service layer  
5. Mobile release APK on Play Store internal track  

---

## Demo script (~3 min)

1. **Landing** — [kick-pro.vercel.app](https://kick-pro.vercel.app/)
2. **Login** — `admin@kickpro.dev` / `admin123456` (seeded on prod after first deploy)
3. **Player flow** — profile → book match → check notifications
4. **Scout flow** — search → bookmark → AI scout assist
5. **Show health** — `curl http://15.188.100.148:8080/actuator/health`
6. **Mention CI** — GitHub Actions badge on README

---

## LinkedIn project blurb (copy-paste)

**KickPro — Football Talent Discovery Platform**

Built a full-stack mobile platform connecting Moroccan football players with scouts and agents.

• Flutter app (46 screens) — multi-role UI (player, scout, agent, admin)  
• Spring Boot API — 127 REST endpoints, JWT auth, WebSocket chat  
• PostgreSQL + Kafka event-driven notifications  
• Google Gemini AI — scout assist, nutrition plans, drill recommendations  
• AWS deployment (EC2 + RDS) + GitHub Actions CI/CD  
• Live: kick-pro.vercel.app · API on AWS  

#Flutter #SpringBoot #Kafka #PostgreSQL #AWS #GeminiAI #Football #Morocco

---

## Files to know (if they ask “show me code”)

| Topic | Path |
|-------|------|
| JWT filter | `backend/.../config/JwtAuthFilter.java` |
| Match booking + lock | `backend/.../service/impl/MatchServiceImpl.java` |
| Kafka consumer | `backend/.../event/MatchBookedEventConsumer.java` |
| Credibility | `backend/.../service/impl/CredibilityServiceImpl.java` |
| API client | `mobile/lib/core/api/api_endpoints.dart` |
| Deploy | `scripts/deploy-aws.sh`, `.github/workflows/backend-ci.yml` |

---

## ADR index

[docs/adr/README.md](adr/README.md)
