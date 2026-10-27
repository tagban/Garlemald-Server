-- XIVLegacy Server: Ul'dah's zone landing (entrance 3, from Meteor's data) is
-- under the floor at -110.157, 202, 171.345, so `!zone Ul'dah` and anything
-- else that lands there put players in the ground. Use the spot the Ul'dah
-- opening quest (man0u1) drops every new player at instead.
UPDATE server_zones_spawnlocations
SET spawnX = -75.242, spawnY = 195.009, spawnZ = 74.572, spawnRotation = -0.046
WHERE id = 3 AND zoneId = 175 AND spawnX = -110.157 AND spawnZ = 171.345;
