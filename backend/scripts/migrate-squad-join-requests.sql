CREATE TABLE IF NOT EXISTS squad_join_requests (
    id BIGSERIAL PRIMARY KEY,
    squad_id BIGINT NOT NULL REFERENCES squads(id) ON DELETE CASCADE,
    player_id BIGINT NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_squad_join_requests_squad_player UNIQUE (squad_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_squad_join_requests_status ON squad_join_requests(status);
CREATE INDEX IF NOT EXISTS idx_squad_join_requests_squad_id ON squad_join_requests(squad_id);
