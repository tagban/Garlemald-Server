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

Names don't need typing in full: any part works (`!camp bent`, a `*` is
fine too), case and apostrophes don't matter (`!zone uldah`), several
matches are listed, and a typo gets a "did you mean". The two places the
client's auto-translate menu (Tab, [Places]) offers, Limsa Lominsa and Central
Shroud, work as well.
