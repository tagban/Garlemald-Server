-- Camp Black Brush: put the Man0u1 camp cast on the ground.
--
-- seed/093 guessed the camp floor at y 201.0 and flagged the rows for
-- in-client tuning. Players standing all over the camp report y 200.00
-- (x 25..56, z -490..-470), so the cast floated a yalm up. The upstream
-- aetheryte row (751) is left alone.
--
-- Idempotent: only rows still at the guessed height move.

UPDATE server_spawn_locations
SET positionY = 200.0
WHERE id BETWEEN 2436 AND 2441 AND zoneId = 170 AND positionY = 201.0;
