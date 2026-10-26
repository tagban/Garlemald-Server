-- XIVLegacy Server: GM levels, per account (every character of the account
-- has it). 0 player, 1 helper, 2 GM, 3 senior GM, 4 administrator. Which
-- level each chat command needs is in settings/commands.toml.
ALTER TABLE users ADD COLUMN gmLevel INTEGER NOT NULL DEFAULT 0;
