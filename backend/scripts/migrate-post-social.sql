-- Run once if feed fails with "column post_type does not exist"
-- docker exec -i kickpro-postgres psql -U kickpro -d kickpro < backend/scripts/migrate-post-social.sql

ALTER TABLE videos ADD COLUMN IF NOT EXISTS post_type VARCHAR(255) NOT NULL DEFAULT 'VIDEO';
ALTER TABLE videos ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP(6);

UPDATE videos SET updated_at = uploaded_at WHERE updated_at IS NULL;

ALTER TABLE videos ALTER COLUMN cloudinary_url DROP NOT NULL;
ALTER TABLE videos ALTER COLUMN skill_tag DROP NOT NULL;
