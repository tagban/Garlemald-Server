-- XIVLegacy Server: zone 177 (_jail) is Mordion Gaol, the GM holding cell. It
-- had no place name (so !zone couldn't find it by name) and no spawn point
-- (so a warp to 0,0,0 left players in empty space). 2,2,2 is inside a cell.
UPDATE server_zones SET placeName = 'Mordion Gaol' WHERE id = 177 AND (placeName IS NULL OR placeName IN ('', '-'));
INSERT INTO server_zones_spawnlocations (zoneId, privateAreaName, spawnType, spawnX, spawnY, spawnZ, spawnRotation)
SELECT 177, NULL, 15, 2.0, 2.0, 2.0, 0.0
WHERE NOT EXISTS (SELECT 1 FROM server_zones_spawnlocations WHERE zoneId = 177);
