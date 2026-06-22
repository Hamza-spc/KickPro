-- Add missing injured flag on player_profiles (Feature 9 injury status).
-- Hibernate added injury_* text columns but injured boolean was skipped on existing DBs.

ALTER TABLE player_profiles
    ADD COLUMN IF NOT EXISTS injured BOOLEAN NOT NULL DEFAULT false;
