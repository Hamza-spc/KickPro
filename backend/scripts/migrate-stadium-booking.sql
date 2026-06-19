-- Stadium booking flow: city + allowed formats
ALTER TABLE stadiums ADD COLUMN IF NOT EXISTS city VARCHAR(100);

UPDATE stadiums SET city = 'Casablanca' WHERE city IS NULL;

CREATE TABLE IF NOT EXISTS stadium_allowed_formats (
    stadium_id BIGINT NOT NULL REFERENCES stadiums(id),
    format_label VARCHAR(20) NOT NULL
);

-- Backfill formats from pitch types where none exist
INSERT INTO stadium_allowed_formats (stadium_id, format_label)
SELECT s.id, '5v5'
FROM stadiums s
WHERE NOT EXISTS (SELECT 1 FROM stadium_allowed_formats saf WHERE saf.stadium_id = s.id)
  AND EXISTS (SELECT 1 FROM stadium_pitch_types spt WHERE spt.stadium_id = s.id AND spt.pitch_type = 'FIVE_V_FIVE');

INSERT INTO stadium_allowed_formats (stadium_id, format_label)
SELECT s.id, '7v7'
FROM stadiums s
WHERE EXISTS (SELECT 1 FROM stadium_pitch_types spt WHERE spt.stadium_id = s.id AND spt.pitch_type = 'SEVEN_V_SEVEN')
  AND NOT EXISTS (SELECT 1 FROM stadium_allowed_formats saf WHERE saf.stadium_id = s.id AND saf.format_label = '7v7');

INSERT INTO stadium_allowed_formats (stadium_id, format_label)
SELECT s.id, '5v5'
FROM stadiums s
WHERE NOT EXISTS (SELECT 1 FROM stadium_allowed_formats saf WHERE saf.stadium_id = s.id);
