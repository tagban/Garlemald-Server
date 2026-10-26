# Settings

| Where | What |
| --- | --- |
| `settings/default/<name>.toml` | Shipped defaults: one machine, localhost. Tracked; don't edit them |
| `settings/<name>.toml` | Your overrides: only what differs. Not tracked, so updates never touch them |

`<name>` is `web`, `lobby`, `world`, `map` or `servers`. Tables in an override
are merged key by key over the defaults; anything else, such as the
`[[servers]]` list, replaces the default outright. `--config <file>` on a
service names a different override file, and `XIVLEGACY_SETTINGS` a different
settings folder.

## Hosting for players on the internet

`settings/web.toml`, `settings/lobby.toml` and `settings/world.toml`, to accept
connections from other machines (the map server stays on 127.0.0.1: only the
world server talks to it):

```toml
[server]
bind_ip = "0.0.0.0"
```

`settings/servers.toml`, the address players are handed:

```toml
[[servers]]
id          = 1
name        = "Fernehalwes"
address     = "xiv.example.com"
lan_address = "auto"
port        = 54992
```

Forward TCP 54992-54994 on your router to the host; never forward 1989.

## GMs and chat commands

Players type commands in chat, starting with `!` (`!zone gridania`). What each
account may use is its GM level against `settings/commands.toml`:

| Level | Name | Gets, by default |
| --- | --- | --- |
| 0 | player | `!help`, `!who`, `!version` |
| 1 | helper | the same (give helpers commands by lowering them to 1) |
| 2 | GM | moving players: `!zone`, `!camp`, `!warp`, `!home`, `!revive`, `!speed` |
| 3 | senior GM | changing characters: `!givegil`, `!giveexp`, grand companies, retainers |
| 4 | administrator | `!setgm`, `!reload`, quest debugging; and any command not listed |

Below `target_others` (GM by default) a command only works on whoever typed
it. `!help` shows each player the commands they have.

**Making the first administrator:** the map server's console isn't limited.
With `host.sh` (or `run-all.sh`), write to its GM FIFO:

```sh
echo "setgm 4 Your Name" > logs/map-server.gm.fifo
```

After that, `!setgm <level> <name>` in game; nobody can grant a level above
their own. Levels belong to the account, so all its characters share one.

**Giving players a command:** lower it in `settings/commands.toml`, for
example to let everyone teleport to camps (not retail behavior, so off by
default):

```toml
[levels]
camp = 0
```

| Command | Does |
| --- | --- |
| `!pos [name]` | Where someone is: zone, coordinates, and the `!warp` that comes back there |
| `!endevent [name]` | Free someone held by a conversation, cutscene or menu |
| `!zone <zone id or name> [name]` | To a zone's spawn point, or beside its aetheryte (`!zone central shroud`, `!zone 155`, `!zone mordion`) |
| `!camp [camp name] [name]` | To an aetheryte camp or gate by part of its name (`!camp bearded rock`); alone, lists the camps |
| `!setgm <level> <name>` | Set the GM level of a character's account |
| `!togglegm [name]` | The GM icon over your head on or off (shows from GM level 2; on by default) |
| `!jail <First Last> [cell] [reason]` / `!pardon <name>` | Hold someone in a Mordion Gaol cell (see below) / release them to their home city |
| `!goto <name>` / `!bring <name>` / `!bringall` | To someone / someone to you / everyone online to you |
| `!send <name> to <name>` / `!return [name]` | One player to another / back to where the last command moved them from |
| `!up [yalms] [name]` / `!down [yalms] [name]` | Straight up or down (5 yalms by default) |
| `!posfix <name>` | To their home city; works offline, for someone who can't log in where they are |
| `!logoff <name>` / `!announce <message>` | Disconnect someone / a message to everyone online |
| `!getid` | What you have targeted: actor id, class, name, position |
| `!additem` `!delitem` `!hasitem <item id> [qty] [name]` | Items (catalog ids) |
| `!addkeyitem` `!delkeyitem` `!haskeyitem <id> [name]` | Key items |
| `!setgil` `!takegil <amount> [name]` | Gil |
| `!addquest` `!completequest` `!delquest <quest id> [name]` | Quests |
| `!addtitle <id>` `!addeffect <status id> [seconds]` `!addallaetherytes` | Titles, status effects, every aetheryte |
| `!setmusic <id> [name]` / `!setweather <id>` | Music for someone / weather for your zone |

The FFXI server's names work too: `!where`, `!ver`, `!raise`, `!kill`,
`!release`, `!promote`, `!homepoint`, `!giveitem`, `!givekeyitem`,
`!fixspeed`, `!reloadglobal`.

**Chat:** leading spaces are ignored, so ` !help` is a command. Start a line
with `!!` to say a command without running it: `!!zone gridania` shows
"!zone gridania" to everyone, for telling players what to type.

### Mordion Gaol

`!jail` holds a character in a gaol cell: they're put back there if they log
in, teleport or are moved out, can't use commands, and only /say reaches
anyone, until `!pardon`. The cells are in `settings/jail.toml`; the shipped
file has one (2, 2, 2). To add cells, stand in each one, use `!pos`, and list
them in order in your `settings/jail.toml`:

```toml
[[cells]]
x = 2.0
y = 2.0
z = 2.0

[[cells]]
x = 12.5
y = 2.0
z = -4.0
```

Where you arrive in the gaol has depended on the zone you came from (from
Gridania the stone cells, from Limsa Lominsa a dark cave), so check each cell
from a couple of places.

Names don't need typing in full: any part works (`!camp bent`, a `*` is
fine too), case and apostrophes don't matter (`!zone uldah`), several
matches are listed, and a typo gets a "did you mean". The two places the
client's auto-translate menu (Tab, [Places]) offers, Limsa Lominsa and Central
Shroud, work as well.
