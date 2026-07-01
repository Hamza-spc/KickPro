#!/usr/bin/env bash
# Deploy KickPro on AWS EC2 (RDS + Docker). Path A / free-tier friendly.
# Triggered automatically by GitHub Actions on push to main.
set -euo pipefail

cd "$(dirname "$0")/.."

COMPOSE=(docker compose -f docker-compose.yml -f docker-compose.aws.yml)

if [[ ! -f .env ]]; then
  echo "ERROR: .env missing. Copy .env.example and set DB_URL (RDS), JWT_SECRET, Cloudinary, Gemini."
  exit 1
fi

if ! grep -q '^DB_URL=jdbc:postgresql://' .env; then
  echo "ERROR: DB_URL must point to RDS in .env"
  exit 1
fi

if grep -qE '^DB_URL=.*//postgres:' .env || grep -qE '^DB_HOST=postgres$' .env; then
  echo "ERROR: .env still uses Docker hostname 'postgres'."
  echo "  RDS → Databases → kickpro-db → copy Endpoint, then set:"
  echo "  DB_URL=jdbc:postgresql://YOUR-RDS-ENDPOINT:5432/kickpro"
  echo "  DB_HOST=YOUR-RDS-ENDPOINT"
  exit 1
fi

echo "==> Ensuring 2G swap (t3.micro OOM guard)..."
if ! swapon --show | grep -q /swapfile; then
  if [[ ! -f /swapfile ]]; then
    sudo fallocate -l 2G /swapfile 2>/dev/null || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
  fi
  sudo swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "==> Stopping old stack..."
"${COMPOSE[@]}" down --remove-orphans 2>/dev/null || true

echo "==> Building backend image..."
"${COMPOSE[@]}" build backend

echo "==> Starting Zookeeper..."
"${COMPOSE[@]}" up -d zookeeper
sleep 6

echo "==> Starting Kafka + Redis..."
"${COMPOSE[@]}" up -d kafka redis

echo "==> Waiting for Kafka (up to 3 min)..."
for _ in $(seq 1 90); do
  if "${COMPOSE[@]}" ps kafka 2>/dev/null | grep -q "(healthy)"; then
    echo "Kafka is healthy."
    break
  fi
  sleep 2
done

if ! "${COMPOSE[@]}" ps kafka 2>/dev/null | grep -q "(healthy)"; then
  echo "WARN: Kafka not healthy yet — check: ${COMPOSE[*]} logs kafka"
fi

echo "==> Starting backend (RDS)..."
"${COMPOSE[@]}" up -d --no-deps backend

echo "==> Waiting for API (up to 5 min — Spring Boot startup)..."
CODE="000"
for _ in $(seq 1 60); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/api/v1/auth/login 2>/dev/null || true)
  CODE=${CODE:-000}
  case "$CODE" in
    400|401|403|405|415|500) break ;;
  esac
  sleep 5
done

echo ""
"${COMPOSE[@]}" ps
echo ""
echo "Local API check HTTP status: $CODE (401/400/405 = OK)"
free -h

case "$CODE" in
  400|401|403|405|415|500) ;;
  *)
  echo ""
  echo "Backend not responding. Logs:"
  "${COMPOSE[@]}" logs --tail=60 backend
  exit 1
  ;;
esac

echo ""
echo "Deploy OK. Test from your Mac:"
PUBLIC_IP=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || true)
PUBLIC_IP=${PUBLIC_IP:-15.188.100.148}
echo "  curl -s -o /dev/null -w '%{http_code}\n' http://${PUBLIC_IP}:8080/api/v1/auth/login"
