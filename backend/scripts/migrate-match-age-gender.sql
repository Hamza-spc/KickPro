-- Match age range and gender restrictions
ALTER TABLE football_matches ADD COLUMN IF NOT EXISTS min_age INTEGER;
ALTER TABLE football_matches ADD COLUMN IF NOT EXISTS max_age INTEGER;
ALTER TABLE football_matches ADD COLUMN IF NOT EXISTS gender VARCHAR(255);

UPDATE football_matches SET min_age = 16 WHERE min_age IS NULL;
UPDATE football_matches SET max_age = 99 WHERE max_age IS NULL;
UPDATE football_matches SET gender = 'MIXED' WHERE gender IS NULL;

ALTER TABLE football_matches ALTER COLUMN min_age SET NOT NULL;
ALTER TABLE football_matches ALTER COLUMN max_age SET NOT NULL;
ALTER TABLE football_matches ALTER COLUMN gender SET NOT NULL;
