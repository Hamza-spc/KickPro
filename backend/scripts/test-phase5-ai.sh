#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:8080}"
TS=$(date +%s)
PLAYER_EMAIL="player5ai_${TS}@test.com"
SCOUT_EMAIL="scout5ai_${TS}@test.com"
PASS="testpass123"

json_field() {
  python3 -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null
}

print_api_error() {
  local body="$1"
  local code="$2"
  if [ "$code" != "200" ]; then
    local msg
    msg=$(echo "$body" | json_field "d.get('message', '')" || true)
    if [ -n "$msg" ] && [ "$msg" != "None" ]; then
      echo "  -> $msg"
    fi
  fi
}

# Load .env from repo root when the key isn't already in the shell (Docker uses env_file separately).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_CALL_DELAY="${AI_CALL_DELAY:-10}"
ENV_FILE="$SCRIPT_DIR/../../.env"
if [ -z "${GEMINI_API_KEY:-}" ] && [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

echo "=== Phase 5 AI API test against $BASE ==="

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "WARNING: GEMINI_API_KEY is not set in your shell or .env — AI endpoints may return 400."
else
  echo "GEMINI_API_KEY loaded (backend uses the same .env via Docker env_file)."
  echo "Note: Gemini free tier rate-limits burst requests. 429 = wait 1–2 min and retry."
fi

echo ""
echo "1. Register player + scout"
PLAYER_REG=$(curl -s -X POST "$BASE/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$PLAYER_EMAIL\",\"password\":\"$PASS\",\"role\":\"PLAYER\"}")
PLAYER_TOKEN=$(echo "$PLAYER_REG" | json_field "d['data']['token']")

SCOUT_REG=$(curl -s -X POST "$BASE/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$SCOUT_EMAIL\",\"password\":\"$PASS\",\"role\":\"SCOUT\"}")
SCOUT_TOKEN=$(echo "$SCOUT_REG" | json_field "d['data']['token']")
echo "  player token ok=${PLAYER_TOKEN:+yes}, scout token ok=${SCOUT_TOKEN:+yes}"

PROFILE='{"fullName":"Phase Five AI Player","dateOfBirth":"2002-06-15","city":"Casablanca","position":"STRIKER","preferredFoot":"RIGHT","bio":"Phase 5 AI test","height":178,"weight":72}'
SKILLS='{"dribbling":7,"shooting":6,"passing":5,"speed":8,"heading":4,"stamina":6}'

echo ""
echo "2. Player profile + skills"
curl -s -o /dev/null -X PUT "$BASE/api/v1/players/profile" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" -d "$PROFILE"
curl -s -o /dev/null -X PUT "$BASE/api/v1/players/skills" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" -d "$SKILLS"
echo "  profile + skills updated"

echo ""
echo "3. Scout assist (Spring AI / Gemini)"
SCOUT_ASSIST=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/scout-assist" \
  -H "Authorization: Bearer $SCOUT_TOKEN" -H "Content-Type: application/json" \
  -d '{"query":"Find promising strikers in Casablanca with good speed"}')
SCOUT_CODE=$(echo "$SCOUT_ASSIST" | tail -1)
SCOUT_BODY=$(echo "$SCOUT_ASSIST" | sed '$d')
echo "  scout-assist: $SCOUT_CODE (expect 200)"
print_api_error "$SCOUT_BODY" "$SCOUT_CODE"
if [ "$SCOUT_CODE" = "200" ]; then
  echo "$SCOUT_BODY" | json_field "d['data']['summary'][:80] if d['data'].get('summary') else 'ok'" || true
fi
sleep "$AI_CALL_DELAY"

echo ""
echo "4. Explain score (player)"
EXPLAIN=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/explain-score" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
EXPLAIN_BODY=$(echo "$EXPLAIN" | sed '$d')
EXPLAIN_CODE=$(echo "$EXPLAIN" | tail -1)
echo "  explain-score: $EXPLAIN_CODE (expect 200)"
print_api_error "$EXPLAIN_BODY" "$EXPLAIN_CODE"
sleep "$AI_CALL_DELAY"

echo ""
echo "5. Recommend drills (player)"
DRILLS=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/recommend-drills" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
DRILLS_BODY=$(echo "$DRILLS" | sed '$d')
DRILLS_CODE=$(echo "$DRILLS" | tail -1)
echo "  recommend-drills: $DRILLS_CODE (expect 200)"
print_api_error "$DRILLS_BODY" "$DRILLS_CODE"
sleep "$AI_CALL_DELAY"

echo ""
echo "6. Meal plan (player)"
MEAL=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/meal-plan" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
MEAL_BODY=$(echo "$MEAL" | sed '$d')
MEAL_CODE=$(echo "$MEAL" | tail -1)
echo "  meal-plan: $MEAL_CODE (expect 200)"
print_api_error "$MEAL_BODY" "$MEAL_CODE"
sleep "$AI_CALL_DELAY"

echo ""
echo "7. Recovery plan (player)"
RECOVERY=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/recovery-plan" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" \
  -d '{"injuryType":"muscle strain","bodyPart":"hamstring","severity":"mild"}')
RECOVERY_BODY=$(echo "$RECOVERY" | sed '$d')
RECOVERY_CODE=$(echo "$RECOVERY" | tail -1)
echo "  recovery-plan: $RECOVERY_CODE (expect 200)"
print_api_error "$RECOVERY_BODY" "$RECOVERY_CODE"
sleep "$AI_CALL_DELAY"

echo ""
echo "8. Generate course (admin login)"
ADMIN_LOGIN=$(curl -s -X POST "$BASE/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@kickpro.dev","password":"admin123456"}')
ADMIN_TOKEN=$(echo "$ADMIN_LOGIN" | json_field "d['data']['token']")
COURSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/ai/generate-course" \
  -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" \
  -d '{"title":"Set Piece Mastery","description":"Corner kicks and free kicks for youth players"}')
COURSE_BODY=$(echo "$COURSE" | sed '$d')
COURSE_CODE=$(echo "$COURSE" | tail -1)
echo "  generate-course: $COURSE_CODE (expect 200), admin token ok=${ADMIN_TOKEN:+yes}"
print_api_error "$COURSE_BODY" "$COURSE_CODE"

echo ""
echo "9. Role guard — player cannot scout-assist"
FORBIDDEN=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/api/v1/ai/scout-assist" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" \
  -d '{"query":"test"}')
echo "  player scout-assist: $FORBIDDEN (expect 403)"

echo ""
echo "=== Phase 5 AI tests finished ==="
