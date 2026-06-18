#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:8080}"
TS=$(date +%s)
PLAYER_EMAIL="player4_${TS}@test.com"
SCOUT_EMAIL="scout4_${TS}@test.com"
PASS="testpass123"

json_field() {
  python3 -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null
}

echo "=== Phase 4 API test against $BASE ==="

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

PROFILE='{"fullName":"Phase Four Player","dateOfBirth":"2002-06-15","city":"Casablanca","position":"STRIKER","preferredFoot":"RIGHT","bio":"Phase 4 test","height":178,"weight":72}'
SKILLS='{"dribbling":7,"shooting":6,"passing":5,"speed":8,"heading":4,"stamina":6}'

echo ""
echo "2. Player profile + skills"
PROFILE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/api/v1/players/profile" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" -d "$PROFILE")
SKILLS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/api/v1/players/skills" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" -d "$SKILLS")
echo "  profile: $PROFILE_CODE (expect 200), skills: $SKILLS_CODE (expect 200)"

echo ""
echo "3. List courses"
COURSES=$(curl -s -w "\n%{http_code}" "$BASE/api/v1/courses" -H "Authorization: Bearer $PLAYER_TOKEN")
COURSES_BODY=$(echo "$COURSES" | sed '$d')
COURSES_CODE=$(echo "$COURSES" | tail -1)
COURSE_ID=$(echo "$COURSES_BODY" | json_field "d['data'][0]['id']")
echo "  courses: $COURSES_CODE (expect 200), courseId=$COURSE_ID"

echo ""
echo "4. Course detail + quiz"
DETAIL_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/api/v1/courses/$COURSE_ID" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
LESSON_ID=$(curl -s "$BASE/api/v1/courses/$COURSE_ID" -H "Authorization: Bearer $PLAYER_TOKEN" \
  | json_field "[l['id'] for l in d['data']['lessons'] if l.get('finalLesson')][0]")
QUIZ=$(curl -s -w "\n%{http_code}" "$BASE/api/v1/courses/$COURSE_ID/lessons/$LESSON_ID/quiz" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
QUIZ_BODY=$(echo "$QUIZ" | sed '$d')
QUIZ_CODE=$(echo "$QUIZ" | tail -1)
Q1=$(echo "$QUIZ_BODY" | json_field "d['data']['questions'][0]['id']")
Q2=$(echo "$QUIZ_BODY" | json_field "d['data']['questions'][1]['id']" || echo "")
echo "  detail: $DETAIL_CODE (expect 200), quiz: $QUIZ_CODE (expect 200), lessonId=$LESSON_ID"

echo ""
echo "5. Submit quiz (pass)"
if [ -n "$Q2" ] && [ "$Q2" != "None" ]; then
  SUBMIT_BODY="{\"answers\":[{\"questionId\":$Q1,\"selectedOptionIndex\":0},{\"questionId\":$Q2,\"selectedOptionIndex\":0}]}"
else
  SUBMIT_BODY="{\"answers\":[{\"questionId\":$Q1,\"selectedOptionIndex\":0}]}"
fi
SUBMIT=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/courses/$COURSE_ID/lessons/$LESSON_ID/quiz/submit" \
  -H "Authorization: Bearer $PLAYER_TOKEN" -H "Content-Type: application/json" -d "$SUBMIT_BODY")
SUBMIT_BODY_OUT=$(echo "$SUBMIT" | sed '$d')
SUBMIT_CODE=$(echo "$SUBMIT" | tail -1)
PASSED=$(echo "$SUBMIT_BODY_OUT" | json_field "d['data']['passed']")
CERT_EARNED=$(echo "$SUBMIT_BODY_OUT" | json_field "d['data']['certificationEarned']")
echo "  submit quiz: $SUBMIT_CODE (expect 200), passed=$PASSED, certificationEarned=$CERT_EARNED"

echo ""
echo "6. Player certifications + credibility"
CERTS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/api/v1/courses/certifications/me" \
  -H "Authorization: Bearer $PLAYER_TOKEN")
SCORE=$(curl -s "$BASE/api/v1/players/profile/me" -H "Authorization: Bearer $PLAYER_TOKEN" \
  | json_field "d['data']['credibilityScore']")
echo "  certifications/me: $CERTS_CODE (expect 200), credibilityScore=$SCORE"

echo ""
echo "7. Scout player search"
SEARCH=$(curl -s -w "\n%{http_code}" "$BASE/api/v1/scouts/players/search?city=Casablanca&position=STRIKER&page=0&size=10" \
  -H "Authorization: Bearer $SCOUT_TOKEN")
SEARCH_CODE=$(echo "$SEARCH" | tail -1)
SEARCH_COUNT=$(echo "$SEARCH" | sed '$d' | json_field "d['data']['totalElements']")
echo "  search: $SEARCH_CODE (expect 200), totalElements=$SEARCH_COUNT"

PLAYER_SEARCH_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  "$BASE/api/v1/scouts/players/search?city=Casablanca" -H "Authorization: Bearer $PLAYER_TOKEN")
echo "  player forbidden search: $PLAYER_SEARCH_CODE (expect 403)"

echo ""
echo "=== Phase 4 tests finished ==="
