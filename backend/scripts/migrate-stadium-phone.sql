-- Stadium phone number
ALTER TABLE stadiums ADD COLUMN IF NOT EXISTS phone_number VARCHAR(30);
