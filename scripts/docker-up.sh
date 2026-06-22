#!/usr/bin/env bash
# Start KickPro stack. Restarts Zookeeper first to clear stale Kafka broker registration.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Starting Zookeeper..."
docker compose up -d zookeeper postgres redis
sleep 5

if docker compose ps postgres 2>/dev/null | grep -q "Up"; then
  echo "Applying DB migrations (post-social)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-post-social.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (post authors -> users)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-post-authors-to-users.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (player follows follower -> users)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-player-follows-follower-to-users.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (admin phase)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-admin-phase.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (stadium phone)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-stadium-phone.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (match age/gender)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-match-age-gender.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (match city)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-match-city.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (stadium booking)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-stadium-booking.sql >/dev/null 2>&1 || true
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-stadium-city-backfill.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (player injury status)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-player-injury.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (announcement image)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-announcement-image.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (squad join requests)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-squad-join-requests.sql >/dev/null 2>&1 || true
  echo "Applying DB migrations (notification types)..."
  docker exec -i kickpro-postgres psql -U kickpro -d kickpro \
    < backend/scripts/migrate-notification-types.sql >/dev/null 2>&1 || true
fi

echo "Starting Kafka..."
docker compose up -d kafka
echo "Waiting for Kafka..."
for _ in $(seq 1 30); do
  if docker compose ps kafka 2>/dev/null | grep -q "(healthy)"; then
    break
  fi
  sleep 2
done

echo "Starting backend + ai-service..."
docker compose up -d backend ai-service

docker compose ps
