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

The Bombard King does no harm and can't be brought below 1 HP by weapons or
spells; ten /firedance emotes at it bring it down, as in 1.0.

The levels needed are in `settings/default/commands.toml`; change them in
`settings/commands.toml`. The commands are Rust, compiled into the map server
(`map-server/src/command_processor/world_end.rs`); this folder only switches
them on.
