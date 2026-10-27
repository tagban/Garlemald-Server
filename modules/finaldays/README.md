# finaldays

The last days of 1.0 as a GM event. Off by default; the commands exist only
while the module is enabled:

```toml
# settings/modules.toml
enabled = ["status", "finaldays"]
```

| Command | Level | Does |
| --- | --- | --- |
| `!worldend` | senior GM (3) | Spawns the Final Days monsters around you and in both halves of each city: three Nael van Darnus with Imperial centurions, Atomos, Bixie, Number 126 and 128, the Great Oak, an Imperial juggernaut and the Bombard King (levels 70-80). Run it again to remove all of them. |

It also lines 12 goobbues up where the Gate of Nald opens onto Central
Thanalan, facing out: the Great Goobbue Wall players made with their mounts
on 1.0's last night (an NPC can't be shown riding one, so they stand on their
own). They never attack and can't be brought down.

The Bombard King does no harm and can't be brought below 1 HP by weapons or
spells; ten /firedance emotes at it bring it down, as in 1.0.

A monster appears only if its actor class has a class path: the 1.23b
client crashes on one without, so those are skipped. The game data leaves
these monsters without one; `common/sql/seed/106_monster_class_paths.sql`
fills them in for all but Atomos, which stays out until it gets one.

The levels needed are in `settings/default/commands.toml`; change them in
`settings/commands.toml`. The commands are Rust, compiled into the map server
(`map-server/src/command_processor/world_end.rs`); this folder only switches
them on.
