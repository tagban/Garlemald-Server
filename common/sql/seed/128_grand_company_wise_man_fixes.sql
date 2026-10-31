-- An Officer and a Wise Man (Com0l5) fixes, after seed 127.
--
-- Merlwyb's model (c010) has only an empty-handed idle animation, so with her
-- pistol in hand she stood in a T-pose; she now stands without it. Thancred
-- stood against a pillar in Maelstrom Command, half hidden and hard to tab
-- to; he moves out onto the open floor.
--
-- Idempotent: each UPDATE is guarded on the value it replaces.

UPDATE "gamedata_actor_appearance" SET "mainHand" = 0
WHERE "id" = 1001568 AND "mainHand" = 243270696;

UPDATE "server_spawn_locations" SET "positionX" = 158.50, "positionZ" = -183.50
WHERE "id" = 27714 AND "positionX" = 156.00 AND "positionZ" = -184.00;
