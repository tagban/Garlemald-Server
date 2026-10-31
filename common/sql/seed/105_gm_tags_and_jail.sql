-- XIVLegacy Server: the GM tag (the GM icon over a character's head, shown
-- while the account is a GM and the tag is on; !togglegm flips it) and the
-- gaol (!jail puts a character in a Mordion Gaol cell until !pardon).
ALTER TABLE users ADD COLUMN gmTag INTEGER NOT NULL DEFAULT 1;
ALTER TABLE characters ADD COLUMN jailCell INTEGER DEFAULT NULL;
ALTER TABLE characters ADD COLUMN jailReason TEXT DEFAULT NULL;
