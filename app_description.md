# KickPro – App Description
# Plain English explanation of what the app does, for every person and feature.
# Claude must read this to understand the product deeply before writing any code.

---

## What is KickPro?

KickPro is a mobile app for football players and scouts.

Imagine you're a talented football player in Casablanca. You're good — really good. But no scout has ever seen you play. You have no agent, no connections, no way to prove your skills to anyone who matters. Your talent goes unnoticed.

Now imagine a scout sitting in an office in Rabat, trying to find a young left-footed striker for their academy. They have no tool to search for players by skill level, no way to verify if a player is actually good, and no time to travel to every city watching games.

KickPro solves both problems at the same time.

It gives players a digital sports CV they can prove — not just claim. And it gives scouts a powerful tool to find, filter, and evaluate players based on real verified data.

---

## Who uses KickPro?

### The Player
A football player between 15 and 30 years old. Could be amateur, semi-professional, or just someone with serious talent who needs visibility. He creates a profile, uploads videos of himself playing, completes skill challenges, joins local matches, and earns certifications. Everything he does on the app builds his credibility score — a number that tells scouts at a glance how good and reliable he is. He also gets access to a personal AI coach that helps him eat right and train smarter.

### The Scout / Recruiter
A professional looking for talent. Could work for a club, an academy, or be an independent agent. He uses KickPro to search for players using specific filters (position, city, age, skill level), watch verified performance videos, read AI-generated scouting reports, and bookmark players he's interested in. He can even type a natural language request like "Find me a fast right winger under 18 in Marrakesh" and the AI does the search for him.

### The Admin
The person who keeps the platform trustworthy. He reviews drill video submissions and decides if they pass or fail. He creates certification courses. He posts announcements about trials and tournaments. Without the admin, the verification system doesn't work.

---

## How does the app work, step by step?

### Step 1: Sign Up
When you open KickPro for the first time, you create an account. You pick your role: are you a Player or a Scout? Each role gets a completely different experience inside the app.

### Step 2: Complete Your Profile
If you're a player, you fill in your profile:
- Name, date of birth, city
- Position (striker, midfielder, defender, goalkeeper)
- Preferred foot (left, right, both)
- Height (in cm) and weight (in kg)
- Profile photo

Then you rate your own skills using a star slider (1 to 10 stars for each skill). You drag the slider smoothly to pick your rating:

```
Dribbling  ★★★★★★☆☆☆☆  6/10
Shooting   ★★★★☆☆☆☆☆☆  4/10
Passing    ★★★★★★★☆☆☆  7/10
Speed      ★★★★★☆☆☆☆☆  5/10
Heading    ★★★☆☆☆☆☆☆☆  3/10
Stamina    ★★★★★★☆☆☆☆  6/10
```

The app automatically determines:
- Strengths = skills rated 7 or above
- Weaknesses = skills rated 4 or below

These ratings power two AI features: the drill recommender and the meal plan generator.

### Step 3: AI Personal Coach (New Feature)
Once the player fills in their profile, a personal AI coach becomes available on their profile page. It has two tools:

#### 🥗 Football Nutrition Plan
The player taps "Get My Meal Plan" and the AI generates a personalized daily nutrition plan based on:
- Their age (a 17-year-old needs different calories than a 25-year-old)
- Their height and weight (to calculate their body's caloric needs)
- Their position (a striker who makes explosive sprints needs different fuel than a goalkeeper)

The plan is specifically designed for footballers — not bodybuilders, not marathon runners. Football requires a mix of explosive energy, endurance, and fast recovery.

The output looks like:
```
Your Daily Football Nutrition Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Calories:  3,100 kcal
Protein:         130g  (muscle recovery)
Carbohydrates:   410g  (match energy)
Fats:            80g   (joint health)

Match Day:
→ Pre-match (3hrs before): Pasta + chicken + water
→ Half time: Banana + isotonic drink
→ Post-match: Protein meal + lots of water

Training Day:
→ Morning: Oats + eggs + fruit juice
→ Lunch: Rice + fish + vegetables
→ Dinner: Chicken + sweet potato + salad

Rest Day:
→ Lighter carbs, same protein
→ Focus on recovery foods: salmon, nuts, berries
```

#### 🎯 Drill Recommendations
The player taps "What Should I Train?" and the AI looks at their weak skills (anything rated 4 or below) and suggests specific drills from the drill tree to work on.

Example:
```
Your weakest skills: Shooting (4/10), Heading (3/10)

Recommended drills for you:
1. Finishing at Target Zones (Intermediate → Step 4)
   → This drill directly improves your shooting accuracy
   
2. Aerial Challenge Drill (Beginner → Step 2)  
   → This drill builds your heading confidence
   
Start with the Beginner heading drill first,
then move to the shooting drill once you feel ready.
```

This is not generic advice — it maps directly to drills that exist in the app's drill tree so the player can go complete them right away.

### Step 4: Upload Performance Videos
Players can upload videos showing themselves playing. Each video is tagged with a skill — for example, a video of fancy footwork is tagged "dribbling", a video of scoring goals is tagged "shooting". Scouts can watch these videos, rate them, and leave feedback. The more views and high ratings a video gets, the better it looks on the player's profile.

### Step 5: Complete Drills (The Core Feature)
This is the heart of KickPro. Drills are skill challenges that players complete in real life and submit video proof of.

Behind the scenes, drills are stored as a **progression tree** (each drill can have a parent drill and an order). That structure powers locking, badges, and AI recommendations.

**What the player sees (Phase 2):** a styled progression list — not a visual tree yet. You pick your level (Beginner, Intermediate, or Advanced), then see drills in order with clear status:

```
[✅] Juggling 20 touches       — completed
[✅] Cone dribbling            — completed
[🔵] Shooting zones            — current (tap to submit)
[🔒] Advanced combo            — locked until previous drills pass
[🔒] Speed drill               — locked
```

**Phase 6 upgrade:** the list is replaced with a full Duolingo-style visual tree (nodes, connectors, glow). Same data, richer UI — built last so the rest of the app ships first.

Example drills:
- Beginner: Juggle the ball 20 times without it dropping
- Intermediate: Dribble through 10 cones in under 30 seconds
- Advanced: Score 3 out of 5 shots at specific target zones

To complete a drill, you record yourself doing it, upload the video, and submit it. An admin watches the video and either approves or rejects it. If approved, you get a score and earn a badge. Badges appear on your profile and boost your visibility in the feed and leaderboard.

Each drill in the system is tagged with a target skill (e.g. shooting, dribbling). This is how the AI coach knows which drills to recommend when a player has a weak skill.

### Step 6: Join Matches
Players can find and join real football matches happening near them. Here's how it works:

Football venues (stadiums, pitches, futsal courts) are listed on the app with photos, location on a map, description, and price per hour. A player books a time slot at a venue and creates a match. He sets how many players are needed (5v5, 7v7, etc.) and the match appears as an open announcement on the app.

Other players in the area see the announcement and request to join. The organizer reviews the requests and accepts or rejects players. Once the match is full, it's confirmed.

All confirmed participants are automatically added to a group chat (chatroom) created specifically for that match. They can coordinate, share directions, and talk before the game.

After the match is played and the organizer marks it as completed, all participants rate each other in four areas:
- Performance: how well did they play technically?
- Punctuality: were they on time?
- Teamwork: did they pass, support teammates, or play selfishly?
- Behavior: were they respectful and sporting?

These ratings feed directly into each player's credibility score.

### Step 7: Earn Certifications
KickPro has a mini learning system with short courses on football topics. Examples:
- Basic Football Tactics (understanding formations, pressing, positioning)
- Discipline On and Off the Pitch (mental strength, respect, professionalism)
- Positioning and Movement (how to read the game, find space)

Each course has lessons (text or short videos) followed by a quiz with multiple choice questions. If you pass the quiz, you earn a certification badge that appears on your profile.

### Step 8: Get Discovered (The Scout Experience)
Scouts have a completely different interface. Their home screen is a discovery feed showing players sorted by credibility score. They can search and filter by position, city, age, skill level, drill scores, certifications, and preferred foot.

They can also use the AI Scout Assistant — a chat interface where they type in plain English what they're looking for. For example: "I need a physically strong center back over 6 feet tall with good heading scores in Casablanca." The AI reads the entire player database, finds the best matches, and explains why each player was selected.

### Step 9: The Credibility Score
Every player has a credibility score from 0 to 100. It's calculated automatically based on:
- Drill scores and how many drills completed
- Average ratings on their videos from scouts
- Post-match ratings from other players
- Number of certifications earned
- Consistency of participation

Players can tap a "Why?" button next to their score and the AI explains it in plain language.

---

## What happens in the background?

### Kafka Events
When something important happens, it triggers a background event:
- Player submits drill video → admin gets notified, AI starts analyzing
- Match gets booked → all participants get a push notification
- Match completed → rating system opens for all participants
- Video uploaded → AI service starts preparing a scouting report

### Cloudinary
Videos and photos go to Cloudinary — a cloud service that stores and streams media. The database only keeps the URL link, not the actual file.

### AI Service (Python)
A separate Python service handles all AI features using Google Gemini (free):
- Scout assistant chatbot
- Scouting reports on videos
- Course content generation
- Credibility score explanation
- Drill recommendations based on weak skill ratings
- Football-specific meal plans based on age, height, weight, position

---

## Summary of All Features

| Feature | What it does |
|---|---|
| Player Profile | Digital sports CV with verified skills and history |
| Skill Star Ratings | Player rates each skill 1–10 via smooth slider |
| AI Meal Plan | Football-specific nutrition plan based on age, height, weight, position |
| AI Drill Recommender | Suggests drills that target the player's weak skills |
| Video Showcase | Upload and share performance videos tagged by skill |
| Drill System | Tree-structured progression (list UI in Phase 2, visual tree in Phase 6) + video proof and admin validation |
| Badge System | Rewards for completing drills, boosts profile visibility |
| Match Booking | Find, create, and join local football matches |
| Stadium Listings | Browse venues with photos, location, and pricing |
| Match Chatroom | Group chat auto-created for each confirmed match |
| Post-Match Ratings | Rate each other on performance, punctuality, teamwork, behavior |
| Credibility Score | Auto-calculated score showing overall player reliability and skill |
| Certification Courses | Short courses with quizzes and badges |
| Scout Search | Advanced filters to find players by any criteria |
| AI Scout Assistant | Natural language search for finding players |
| AI Video Feedback | Automatic scouting report on player videos |
| AI Score Explainer | Plain language explanation of credibility score |
| AI Course Generator | Admin auto-generates course content with one click |
| Leaderboard | Top players ranked by credibility score |
| Bookmarks | Scouts save interesting player profiles |
| Announcements Feed | Trials, tournaments, and news from scouts and admins |

---

## Build Order
For every phase: backend is built and tested with Postman FIRST. Flutter screens are built AFTER the backend is confirmed working.

### Drill UI roadmap (Option C)
1. **Phase 2:** Backend drill tree entities + progression list UI (✅ / 🔵 / 🔒)
2. **Phases 3–5:** Keep using the list — no drill UI work unless fixing bugs
3. **Phase 6 (last):** Upgrade to full Duolingo-style visual tree — UI only, no backend changes

---

## Additional Features

### Player Comparison Tool
Scouts can pick any two players from their search results or bookmarks and compare them side by side on a single screen. Every stat appears in two columns — credibility score, skill ratings, drill scores, match ratings, certifications. Visual bars make it instantly clear who is stronger in each area. This is especially useful when a scout has narrowed down to two candidates for one position and needs to make a final decision.

### Match History Timeline
Every player's profile has a timeline tab that shows their complete football journey in chronological order. Every important event appears here: the day they completed their first advanced drill and earned a badge, the match they played last month where they got a 4.8 rating, the certification they earned in tactics, the video that got 200 views. Scouts love this because it shows consistency — a player who has been active for 6 months with steady progress is far more credible than someone who just joined last week.

### Scout Feedback on Player Profiles
After a scout views a player's profile, they can leave private structured feedback. They rate the player's technical ability and potential (both out of 5) and write a personal note. The scout sees this as their own scouting notebook — a way to remember their thoughts on players they've viewed. The player sees the feedback as motivation and professional guidance. It's private — no one else can see it. This creates a real connection between scouts and players even before any formal contact.

### Weekly Challenges
Every Monday, a new challenge goes live for all players. Example challenges: "Most Juggling Touches This Week", "Best Goal Scored", "Fastest Cone Drill". Players record themselves attempting the challenge and submit their video. Other players and scouts can vote for their favorite submissions. At the end of the week, the admin picks the winner (or the most voted entry wins). The winner gets a special "Challenge Champion" badge that appears prominently on their profile for the next 7 days, boosting their visibility in the feed and search results. This keeps the platform active and gives players a reason to come back every week.

### Position-Specific Leaderboards
Instead of one big global leaderboard where everyone competes against everyone, KickPro has filtered leaderboards. A 16-year-old goalkeeper in Casablanca doesn't need to compete against a 25-year-old striker in Rabat. The leaderboards can be filtered by position (striker, midfielder, defender, goalkeeper), by city or region, and by age group (Under 18, Under 21, Open age). This makes the leaderboard relevant and achievable — players feel like they have a real chance of appearing on it, which motivates them to be more active.

### Injury Tracker and Recovery Plan
Players can mark themselves as currently injured. They select the injury type (muscle, joint, bone) and the body part affected (knee, hamstring, ankle etc.) and rate the severity. Once marked as injured, two things change automatically. First, the AI meal plan switches from a performance nutrition plan to a recovery-focused plan — more anti-inflammatory foods, the right protein for muscle repair, proper hydration. Second, the AI drill recommender stops suggesting performance drills and instead suggests safe rehabilitation exercises appropriate for their injury. The player's profile shows a "Currently Recovering" status so match organizers and scouts are aware. Once the player marks themselves as recovered, everything goes back to normal.

### Agent and Club Account Type
In addition to Players, Scouts, and Admins, KickPro supports a fourth type of account: Agents. An agent could represent a football academy, a club's recruitment department, or be an independent licensed agent. After creating an account and getting verified by the admin (who checks their license number), agents get a verified badge. Agents can post official trial announcements that look different from regular announcements — they appear with an official badge and are prioritized in the feed. Agents can directly message players they're interested in through a priority inbox. They also get access to more detailed player data including private drill submissions. This makes KickPro a complete ecosystem — not just for discovery, but for actual recruitment transactions.
