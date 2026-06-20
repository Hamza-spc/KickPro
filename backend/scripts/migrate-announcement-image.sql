-- Add optional image URL for announcements/trials.

ALTER TABLE announcements
    ADD COLUMN IF NOT EXISTS image_url TEXT;

