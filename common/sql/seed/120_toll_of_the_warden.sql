-- Toll of the Warden (Man300, the shared level 30 story): the Ashcrown
-- Consortium, its cast, and the quest's triggers.
--
-- The Consortium is Gridania's counterpart of the Waking Sands: zone 161
-- (Peasants Ward) was a stub with no map name. The client's region table
-- (data/03/C0/00/00.DAT) puts Gridania's private layouts, prv_f0, in region
-- 204 (with the Market Wards), and the Consortium layout prv_f0_mlt01 names
-- its map fst0Event01 (data/72/9F/00/00.DAT).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "server_zones" SET
    "regionId" = 204,
    "zoneName" = 'fst0Event01',
    "classPath" = '/Area/Zone/ZoneMasterFstF0'
WHERE "id" = 161 AND ("zoneName" IS NULL OR "zoneName" = '');
