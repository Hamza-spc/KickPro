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
A football player between 15 and 30 years old. Could be amateur, semi-professional, or just someone with serious talent who needs visibility. He creates a profile, uploads videos of himself playing, completes skill challenges, joins local matches, and earns certifications. Everything he does on the app builds his credibility score — a number that tells scouts at a glance how good and reliable he is.

### The Scout / Recruiter
A professional looking for talent. Could work for a club, an academy, or be an independent agent. He uses KickPro to search for players using specific filters (position, city, age, skill level), watch verified performance videos, read AI-generated scouting reports, and bookmark players he's interested in. He can even type a natural language request like "Find me a fast right winger under 18 in Marrakesh" and the AI does the search for him.

### The Admin
The person who keeps the platform trustworthy. He reviews drill video submissions and decides if they pass or fail. He creates certification courses. He posts announcements about trials and tournaments. Without the admin, the verification system doesn't work.

---

## How does the app work, step by step?

### Step 1: Sign Up
When you open KickPro for the first time, you create an account. You pick your role: are you a Player or a Scout? Each role gets a completely different experience inside the app.

### Step 2: Complete Your Profile
If you're a player, you fill in your profile: name, age, city, position (striker, midfielder, defender, goalkeeper), preferred foot (left, right, both), and you rate your own skills from 0 to 100 in six areas: dribbling, shooting, passing, speed, heading, and stamina. You also upload a profile photo. This becomes your digital sports identity.

### Step 3: Upload Performance Videos
Players can upload videos showing themselves playing. Each video is tagged with a skill — for example, a video of fancy footwork is tagged "dribbling", a video of scoring goals is tagged "shooting". Scouts can watch these videos, rate them, and leave feedback. The more views and high ratings a video gets, the better it looks on the player's profile.

### Step 4: Complete Drills (The Core Feature)
This is the heart of KickPro. Drills are skill challenges that players complete in real life and submit video proof of.

When you enter the drill section, you first pick your level: Beginner, Intermediate, or Advanced. Then you see a tree — like the skill tree in Duolingo. Each node on the tree is a drill. You start from the bottom and work your way up.

Example drills:
- Beginner: Juggle the ball 20 times without it dropping
- Intermediate: Dribble through 10 cones in under 30 seconds
- Advanced: Score 3 out of 5 shots at specific target zones

To complete a drill, you record yourself doing it, upload the video, and submit it. An admin watches the video and either approves or rejects it. If approved, you get a score and earn a badge. Badges appear on your profile and boost your visibility in the feed and leaderboard.

The whole drill system is gamified — the more drills you complete, the more badges you collect, the higher you rank, and the more scouts notice you.

### Step 5: Join Matches
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

### Step 6: Earn Certifications
KickPro has a mini learning system with short courses on football topics. Examples:
- Basic Football Tactics (understanding formations, pressing, positioning)
- Discipline On and Off the Pitch (mental strength, respect, professionalism)
- Positioning and Movement (how to read the game, find space)

Each course has lessons (text or short videos) followed by a quiz with multiple choice questions. If you pass the quiz, you earn a certification badge that appears on your profile. Scouts can see these certifications and know you've invested in your development.

An AI can also auto-generate course content: an admin just gives a topic title, and the AI writes the lessons and quiz questions automatically.

### Step 7: Get Discovered (The Scout Experience)
Scouts have a completely different interface. Their home screen is a discovery feed showing players sorted by credibility score. They can search and filter by:
- Position (striker, midfielder, defender, goalkeeper)
- City or region
- Age range
- Skill level
- Drill scores
- Certifications earned
- Preferred foot

They can also use the AI Scout Assistant — a chat interface where they type in plain English what they're looking for. For example: "I need a physically strong center back over 6 feet tall with good heading scores in Casablanca." The AI reads the entire player database, finds the best matches, and explains why each player was selected.

Scouts can bookmark players they like, watch their videos, see their drill scores and certifications, and read AI-generated scouting reports on their videos.

### Step 8: The Credibility Score
Every player has a credibility score from 0 to 100. It's calculated automatically based on:
- Drill scores and how many drills completed
- Average ratings on their videos from scouts
- Post-match ratings from other players
- Number of certifications earned
- Consistency of participation

This score is the most important number on a player's profile. It's what scouts see first. A player with a 85/100 credibility score has proven themselves across multiple dimensions — not just claimed to be good.

Players can tap a "Why?" button next to their score and the AI explains it in plain language: "Your score is 72/100. Your dribbling drills are strong (85/100 average) but your match participation is low. Playing more matches would significantly boost your score."

---

## What happens in the background (things users don't see)?

### Kafka Events
When something important happens in the app, it triggers a background event that other parts of the system react to:
- Player submits drill video → admin gets notified instantly, AI starts analyzing
- Match gets booked → all participants get a push notification
- Match completed → rating system opens for all participants
- Video uploaded → AI service starts preparing a scouting report

### Cloudinary
When a player uploads a video or photo, it goes to Cloudinary — a cloud service that stores and streams media. The app never stores actual video files in the database. It only keeps a link (URL) to where the video lives on Cloudinary. This makes everything fast and scalable.

### AI Service (Python)
A separate Python service handles all AI features. It connects to Google Gemini (a free AI model) to:
- Power the scout assistant chatbot
- Generate scouting reports on videos
- Create course content automatically
- Explain credibility scores
- Recommend which drills to do next

---

## What makes KickPro different from Instagram or YouTube?

On Instagram or YouTube, a player can post highlights. But:
- Anyone can post anything — there's no verification
- A scout can't filter by position, city, or drill score
- There's no credibility system — a smooth video edit doesn't mean the player is actually good
- There's no way to organize or join local matches
- There are no structured skill development paths

KickPro is not a social media platform. It's a professional sports tool. Every feature is designed around one goal: making talent verifiable and discoverable.

---

## The Feed and Announcements
The main feed shows:
- Recent player videos (public performance content)
- Drill completion announcements ("Hamza just completed the Advanced Shooting drill!")
- Match announcements (open matches looking for players)
- Official announcements from scouts and admins (trials, tournaments, news)

---

## Summary of All Features

| Feature | What it does |
|---|---|
| Player Profile | Digital sports CV with verified skills and history |
| Video Showcase | Upload and share performance videos tagged by skill |
| Drill System | Gamified skill challenges with video proof and admin validation |
| Badge System | Rewards for completing drills, boosts profile visibility |
| Match Booking | Find, create, and join local football matches |
| Stadium Listings | Browse venues with photos, location, and pricing |
| Match Chatroom | Group chat auto-created for each confirmed match |
| Post-Match Ratings | Rate each other on performance, punctuality, teamwork, behavior |
| Credibility Score | Auto-calculated score showing overall player reliability and skill |
| Certification Courses | Short courses with quizzes and badges |
| Scout Search | Advanced filters to find players by any criteria |
| AI Scout Assistant | Natural language search for finding players |
| AI Video Feedback | Automatic scouting report generation on player videos |
| AI Score Explainer | Plain language explanation of a player's credibility score |
| AI Drill Recommender | Personalized drill path based on weak skills |
| AI Course Generator | Admin can auto-generate course content with one click |
| Leaderboard | Top players ranked by credibility score |
| Bookmarks | Scouts save interesting player profiles |
| Announcements Feed | Trials, tournaments, and news from scouts and admins |
