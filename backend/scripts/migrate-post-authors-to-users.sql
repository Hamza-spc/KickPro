-- Allow scouts/agents to comment and react (author/reactor references users, not player_profiles)
-- docker exec -i kickpro-postgres psql -U kickpro -d kickpro < backend/scripts/migrate-post-authors-to-users.sql

ALTER TABLE post_comments DROP CONSTRAINT IF EXISTS fk1m33pdi8qvd9cc47tknabvxgd;
ALTER TABLE post_comments DROP CONSTRAINT IF EXISTS fk_post_comments_author_user;

UPDATE post_comments pc
SET author_id = pp.user_id
FROM player_profiles pp
WHERE pp.id = pc.author_id;

ALTER TABLE post_comments
    ADD CONSTRAINT fk_post_comments_author_user FOREIGN KEY (author_id) REFERENCES users(id);

ALTER TABLE post_reactions DROP CONSTRAINT IF EXISTS fk1iy7uob2nry4mxu8nx0hinay8;
ALTER TABLE post_reactions DROP CONSTRAINT IF EXISTS fk_post_reactions_reactor_user;

UPDATE post_reactions pr
SET reactor_id = pp.user_id
FROM player_profiles pp
WHERE pp.id = pr.reactor_id;

ALTER TABLE post_reactions
    ADD CONSTRAINT fk_post_reactions_reactor_user FOREIGN KEY (reactor_id) REFERENCES users(id);
