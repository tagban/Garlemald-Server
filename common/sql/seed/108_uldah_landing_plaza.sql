-- XIVLegacy Server: 107 moved Ul'dah's landing (entrance 3) to the spot the
-- opening quest leaves new players, which is inside the Quicksand: the room
-- is so cramped the camera jams against the walls and points at the floor.
-- Land in the aetheryte plaza instead, on its floor (y 186; 185 is just
-- below it), where Return and home-point teleports also arrive.
UPDATE server_zones_spawnlocations
SET spawnX = -230.0, spawnY = 186.0, spawnZ = -3.9, spawnRotation = 0.0
WHERE id = 3 AND zoneId = 175;
