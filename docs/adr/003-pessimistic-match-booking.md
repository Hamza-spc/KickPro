# ADR 003: Pessimistic locking for match booking

## Status

Accepted — June 2026

## Context

Two players (or two organizers) could book the **same stadium slot** at the same time. A classic **lost update** / double-booking race:

1. Request A reads availability → slot free  
2. Request B reads availability → slot free  
3. Both insert a `Match` → conflict  

KickPro uses **90-minute match windows** (`Match.DEFAULT_DURATION_MINUTES`) and overlap queries in `findOverlappingMatches`.

## Decision

In `MatchServiceImpl.createMatch`, **before** conflict checks and insert:

```java
matchRepository.lockStadiumForBooking(request.getStadiumId());
```

`MatchRepository.lockStadiumForBooking` uses JPA **`PESSIMISTIC_WRITE`** on the `Stadium` row. Concurrent bookings for the same stadium serialize on that row; the second transaction waits, then fails `assertNoBookingConflict` if the slot is taken.

Flow:

1. Lock stadium row  
2. Load stadium + `assertNoBookingConflict` (overlap query)  
3. Validate business rules (15 min in future, age range, etc.)  
4. Save match + organizer participant  
5. Publish `match.booked` Kafka event  

## Consequences

- **Pros:** Correct under concurrent load without distributed locks; easy to reason about in PostgreSQL transactions.
- **Cons:** Serializes all bookings **per stadium** (not per time slot); possible queueing under heavy contention (acceptable at MVP scale).
- **Not used for:** Join requests, ratings — only stadium booking creation.

## Alternatives considered

| Option | Trade-off |
|--------|-----------|
| **Optimistic locking (`@Version`)** | Fails after work; bad UX for booking (user retries) |
| **Redis distributed lock** | Infra present but unused; adds failure mode |
| **DB unique constraint on (stadium_id, slot)** | Hard to model 90-min overlaps with simple UNIQUE |
| **Serializable isolation** | Broader contention than row lock on stadium |

## Related code

- `MatchRepository.lockStadiumForBooking`
- `MatchServiceImpl.assertNoBookingConflict`
- `StadiumServiceImpl.getAvailability` (read path, no lock)
