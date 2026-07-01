# ADR 002: Kafka event bus (producer + consumer)

## Status

Accepted — Phase 4 (June 2026)

## Context

KickPro publishes domain events when matches are booked, completed, drills submitted, and videos uploaded.  
Initially only **producers** existed (`KafkaEventPublisher`), which made the stack hard to describe honestly as event-driven.

## Decision

1. Keep a **single Spring Boot** deployment (no microservices split).
2. Run **Kafka in Docker** locally and on AWS EC2 (Path A free tier).
3. Add **`MatchBookedEventConsumer`** listening to `match.booked` with consumer group `kickpro-backend`.
4. On consume → persist an in-app notification (`NotificationType.MATCH_BOOKED`) for the match organizer.

### Topics (producer today)

| Topic | Producer trigger | Consumer (Phase 4) |
|-------|------------------|--------------------|
| `match.booked` | `MatchServiceImpl.createMatch` | **Yes** — `MatchBookedEventConsumer` |
| `match.completed` | Match completion | No (future) |
| `drill.submitted` | Drill submission | No (future) |
| `video.uploaded` | Video upload | No (future) |

## Consequences

- **Pros:** End-to-end event flow demonstrable in interviews; booking side effects decoupled from HTTP response path.
- **Cons:** Duplicate notification risk if we also call `notifyUser` directly in `createMatch` (avoided); consumer adds DB write latency after Kafka delivery.
- **Ops:** If Kafka is down, producer logs and continues; consumer catches up when Kafka returns.

## Alternatives considered

- **AWS MSK:** Rejected for cost on student free tier.
- **Redis pub/sub:** Already in stack but not used; Kafka kept for portfolio narrative.
- **Synchronous notification only:** Simpler but does not prove consumer pattern.
