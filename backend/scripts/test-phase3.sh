#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:8080}"
TS=$(date +%s)
ORG_EMAIL="organizer_${TS}@test.com"
JOIN_EMAIL="joiner_${TS}@test.com"
PASS="testpass123"

json_field() {
  python3 -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null
}

echo "=== Phase 3 API test against $BASE ==="

echo ""
echo "1. Register organizer + joiner"
ORG_REG=$(curl -s -X POST "$BASE/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ORG_EMAIL\",\"password\":\"$PASS\",\"role\":\"PLAYER\"}")
ORG_TOKEN=$(echo "$ORG_REG" | json_field "d['data']['token']")
echo "  organizer registered, token ok=${ORG_TOKEN:+yes}"

JOIN_REG=$(curl -s -X POST "$BASE/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$JOIN_EMAIL\",\"password\":\"$PASS\",\"role\":\"PLAYER\"}")
JOIN_TOKEN=$(echo "$JOIN_REG" | json_field "d['data']['token']")
echo "  joiner registered, token ok=${JOIN_TOKEN:+yes}"

PROFILE='{"fullName":"Test Player","dateOfBirth":"2000-01-15","city":"Casablanca","position":"STRIKER","preferredFoot":"RIGHT","bio":"Test","height":175,"weight":70}'

echo ""
echo "2. Create player profiles"
ORG_PROFILE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/api/v1/players/profile" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" -d "$PROFILE")
JOIN_PROFILE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/api/v1/players/profile" \
  -H "Authorization: Bearer $JOIN_TOKEN" -H "Content-Type: application/json" -d "$PROFILE")
echo "  organizer profile: $ORG_PROFILE_CODE, joiner profile: $JOIN_PROFILE_CODE"

echo ""
echo "3. GET /stadiums"
NO_AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/api/v1/stadiums")
ORG_STADIUMS=$(curl -s -w "\n%{http_code}" "$BASE/api/v1/stadiums" -H "Authorization: Bearer $ORG_TOKEN")
ORG_STADIUMS_BODY=$(echo "$ORG_STADIUMS" | sed '$d')
ORG_STADIUMS_CODE=$(echo "$ORG_STADIUMS" | tail -1)
JOIN_STADIUMS=$(curl -s -w "\n%{http_code}" "$BASE/api/v1/stadiums" -H "Authorization: Bearer $JOIN_TOKEN")
JOIN_STADIUMS_BODY=$(echo "$JOIN_STADIUMS" | sed '$d')
JOIN_STADIUMS_CODE=$(echo "$JOIN_STADIUMS" | tail -1)
echo "  no auth: $NO_AUTH_CODE (expect 401)"
echo "  organizer: $ORG_STADIUMS_CODE (expect 200)"
echo "  joiner: $JOIN_STADIUMS_CODE (expect 200)"
STADIUM_ID=$(echo "$ORG_STADIUMS_BODY" | json_field "d['data'][0]['id']")
STADIUM_COUNT=$(echo "$ORG_STADIUMS_BODY" | json_field "len(d['data'])")
echo "  stadiums found: $STADIUM_COUNT, using stadiumId=$STADIUM_ID"

echo ""
echo "4. Create match"
MATCH_DATE=$(python3 -c "from datetime import datetime,timedelta; import random; print((datetime.now(datetime.UTC)+timedelta(days=30, hours=random.randint(1,12), minutes=random.randint(0,59))).strftime('%Y-%m-%dT%H:%M:%S'))" 2>/dev/null || python3 -c "from datetime import datetime,timedelta,timezone; import random; print((datetime.now(timezone.utc)+timedelta(days=30, hours=random.randint(1,12), minutes=random.randint(0,59))).strftime('%Y-%m-%dT%H:%M:%S'))")
CREATE_MATCH=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/matches" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d "{\"stadiumId\":$STADIUM_ID,\"dateTime\":\"$MATCH_DATE\",\"maxPlayers\":4}")
CREATE_BODY=$(echo "$CREATE_MATCH" | sed '$d')
CREATE_CODE=$(echo "$CREATE_MATCH" | tail -1)
MATCH_ID=$(echo "$CREATE_BODY" | json_field "d['data']['id']" || true)
if [ -z "$MATCH_ID" ] || [ "$MATCH_ID" = "None" ]; then
  echo "  create match FAILED: HTTP $CREATE_CODE"
  echo "$CREATE_BODY"
  exit 1
fi
echo "  create match: $CREATE_CODE (expect 201), matchId=$MATCH_ID"

echo ""
echo "5. Join + approve"
JOIN_RES=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/matches/$MATCH_ID/join" \
  -H "Authorization: Bearer $JOIN_TOKEN")
JOIN_BODY=$(echo "$JOIN_RES" | sed '$d')
JOIN_CODE=$(echo "$JOIN_RES" | tail -1)
PARTICIPANT_ID=$(echo "$JOIN_BODY" | json_field "[p['id'] for p in d['data']['participants'] if p['status']=='PENDING'][0]")
echo "  join request: $JOIN_CODE (expect 200), participantId=$PARTICIPANT_ID"

APPROVE_RES=$(curl -s -w "\n%{http_code}" -X PUT "$BASE/api/v1/matches/$MATCH_ID/participants/$PARTICIPANT_ID/review" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d '{"status":"APPROVED"}')
APPROVE_BODY=$(echo "$APPROVE_RES" | sed '$d')
APPROVE_CODE=$(echo "$APPROVE_RES" | tail -1)
MATCH_STATUS=$(echo "$APPROVE_BODY" | json_field "d['data']['status']")
CHAT_ROOM_ID=$(echo "$APPROVE_BODY" | json_field "d['data'].get('chatRoomId') or 'null'")
echo "  approve: $APPROVE_CODE, match status=$MATCH_STATUS, chatRoomId=$CHAT_ROOM_ID"

echo ""
echo "6. Double-booking prevention"
DOUBLE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/api/v1/matches" \
  -H "Authorization: Bearer $JOIN_TOKEN" -H "Content-Type: application/json" \
  -d "{\"stadiumId\":$STADIUM_ID,\"dateTime\":\"$MATCH_DATE\",\"maxPlayers\":4}")
echo "  overlapping booking: $DOUBLE_CODE (expect 400)"

echo ""
echo "7. Chat"
CHAT_FAIL=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/api/v1/matches/$MATCH_ID/chat/messages" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d '{"content":"Before full test"}')
echo "  chat when not full: $CHAT_FAIL (expect 400 if not FULL)"

# Fill match to FULL if needed (maxPlayers=4, organizer already approved = 2 approved)
# Need 2 more players or lower maxPlayers - recreate with maxPlayers=2 for simpler test
MATCH2_DATE=$(python3 -c "from datetime import datetime,timedelta; import random; print((datetime.now(datetime.UTC)+timedelta(days=31, hours=random.randint(1,12), minutes=random.randint(0,59))).strftime('%Y-%m-%dT%H:%M:%S'))" 2>/dev/null || python3 -c "from datetime import datetime,timedelta,timezone; import random; print((datetime.now(timezone.utc)+timedelta(days=31, hours=random.randint(1,12), minutes=random.randint(0,59))).strftime('%Y-%m-%dT%H:%M:%S'))")
CREATE2=$(curl -s -X POST "$BASE/api/v1/matches" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d "{\"stadiumId\":$STADIUM_ID,\"dateTime\":\"$MATCH2_DATE\",\"maxPlayers\":2}")
MATCH2_ID=$(echo "$CREATE2" | json_field "d['data']['id']")
curl -s -X POST "$BASE/api/v1/matches/$MATCH2_ID/join" -H "Authorization: Bearer $JOIN_TOKEN" > /dev/null
JOIN2=$(curl -s "$BASE/api/v1/matches/$MATCH2_ID" -H "Authorization: Bearer $ORG_TOKEN")
P2_ID=$(echo "$JOIN2" | json_field "[p['id'] for p in d['data']['participants'] if p['status']=='PENDING'][0]")
FULL_RES=$(curl -s -X PUT "$BASE/api/v1/matches/$MATCH2_ID/participants/$P2_ID/review" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d '{"status":"APPROVED"}')
FULL_STATUS=$(echo "$FULL_RES" | json_field "d['data']['status']")
CHAT_ROOM2=$(echo "$FULL_RES" | json_field "d['data'].get('chatRoomId')")
echo "  full match status=$FULL_STATUS, chatRoomId=$CHAT_ROOM2"

MSG_RES=$(curl -s -w "\n%{http_code}" -X POST "$BASE/api/v1/matches/$MATCH2_ID/chat/messages" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d '{"content":"See you on the pitch!"}')
MSG_CODE=$(echo "$MSG_RES" | tail -1)
echo "  send chat message: $MSG_CODE (expect 201)"

HIST_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/api/v1/matches/$MATCH2_ID/chat/messages" \
  -H "Authorization: Bearer $JOIN_TOKEN")
echo "  chat history: $HIST_CODE (expect 200)"

echo ""
echo "8. Complete match + ratings"
COMPLETE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/api/v1/matches/$MATCH2_ID/complete" \
  -H "Authorization: Bearer $ORG_TOKEN")
JOINER_PROFILE_ID=$(curl -s "$BASE/api/v1/players/profile/me" -H "Authorization: Bearer $JOIN_TOKEN" | json_field "d['data']['id']")
RATE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/api/v1/matches/$MATCH2_ID/ratings" \
  -H "Authorization: Bearer $ORG_TOKEN" -H "Content-Type: application/json" \
  -d "{\"ratedPlayerId\":$JOINER_PROFILE_ID,\"performanceScore\":4,\"punctualityScore\":5,\"teamworkScore\":4,\"behaviorScore\":5}")
echo "  complete: $COMPLETE_CODE (expect 200), rating: $RATE_CODE (expect 201)"

echo ""
echo "=== Phase 3 tests finished ==="
