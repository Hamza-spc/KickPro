-- Match city for filtering open matches
ALTER TABLE football_matches ADD COLUMN IF NOT EXISTS city VARCHAR(100);

UPDATE football_matches fm
SET city = pp.city
FROM player_profiles pp
WHERE fm.organizer_id = pp.user_id
  AND fm.city IS NULL;

UPDATE football_matches SET city = 'Casablanca' WHERE city IS NULL;

ALTER TABLE football_matches ALTER COLUMN city SET NOT NULL;
