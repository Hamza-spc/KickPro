-- Allow scouts/agents to follow players (follower references users, not player_profiles)
-- docker exec -i kickpro-postgres psql -U kickpro -d kickpro < backend/scripts/migrate-player-follows-follower-to-users.sql

ALTER TABLE player_follows DROP CONSTRAINT IF EXISTS fk_player_follows_follower;
ALTER TABLE player_follows DROP CONSTRAINT IF EXISTS fk_player_follows_follower_user;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
    WHERE tc.table_name = 'player_follows'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND kcu.column_name = 'follower_id'
      AND ccu.table_name = 'player_profiles'
  ) THEN
    EXECUTE (
      SELECT 'ALTER TABLE player_follows DROP CONSTRAINT ' || quote_ident(tc.constraint_name)
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
      WHERE tc.table_name = 'player_follows'
        AND tc.constraint_type = 'FOREIGN KEY'
        AND kcu.column_name = 'follower_id'
        AND ccu.table_name = 'player_profiles'
      LIMIT 1
    );
  END IF;
END $$;

UPDATE player_follows pf
SET follower_id = pp.user_id
FROM player_profiles pp
WHERE pp.id = pf.follower_id;

ALTER TABLE player_follows
    ADD CONSTRAINT fk_player_follows_follower_user FOREIGN KEY (follower_id) REFERENCES users(id);
