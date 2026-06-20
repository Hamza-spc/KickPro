-- Fix legacy stadium rows where city was backfilled to Casablanca but location indicates another city.
UPDATE stadiums SET city = 'Rabat'
WHERE city = 'Casablanca' AND location ILIKE '%rabat%';

UPDATE stadiums SET city = 'Marrakech'
WHERE city = 'Casablanca' AND (location ILIKE '%marrakech%' OR location ILIKE '%gueliz%');

UPDATE stadiums SET city = 'Fes'
WHERE city = 'Casablanca' AND location ILIKE '%fes%';

UPDATE stadiums SET city = 'Tanger'
WHERE city = 'Casablanca' AND (location ILIKE '%tanger%' OR location ILIKE '%tangier%');

UPDATE stadiums SET city = 'Agadir'
WHERE city = 'Casablanca' AND location ILIKE '%agadir%';

UPDATE stadiums SET city = 'Oujda'
WHERE city = 'Casablanca' AND location ILIKE '%oujda%';

UPDATE stadiums SET city = 'Meknes'
WHERE city = 'Casablanca' AND location ILIKE '%meknes%';
