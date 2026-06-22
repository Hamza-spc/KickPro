-- Extend notification type check constraint for direct messages and squad join flows.
ALTER TABLE app_notifications DROP CONSTRAINT IF EXISTS app_notifications_type_check;

ALTER TABLE app_notifications ADD CONSTRAINT app_notifications_type_check
CHECK (type IN (
    'MATCH_BOOKED',
    'MATCH_JOIN_REQUEST',
    'MATCH_JOIN_APPROVED',
    'DRILL_APPROVED',
    'DRILL_REJECTED',
    'ANNOUNCEMENT',
    'CHALLENGE',
    'DIRECT_MESSAGE',
    'SQUAD_JOIN_REQUEST',
    'SQUAD_JOIN_APPROVED',
    'SQUAD_JOIN_REJECTED',
    'GENERAL'
));
